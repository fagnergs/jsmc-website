#!/bin/bash
# deploy-website.sh - Deploy website para Azure Storage
#
# Este script faz upload dos arquivos do website para o Azure Storage Account
#
# PRÉ-REQUISITOS:
# 1. Infraestrutura Azure já provisionada (provision-all.sh executado)
# 2. Azure CLI autenticado
# 3. Arquivo azure-config.sh configurado
#
# USO:
#   source azure-config.sh
#   chmod +x deploy-website.sh
#   ./deploy-website.sh

set -e
set -u

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Carregar configurações
if [ ! -f "azure-config.sh" ]; then
    echo "❌ Arquivo azure-config.sh não encontrado!"
    exit 1
fi

source ./azure-config.sh

echo ""
echo "=========================================="
echo "JSMC Website - Deploy para Azure"
echo "=========================================="
echo ""
echo "Storage Account: ${STORAGE_ACCOUNT_NAME}"
echo "Container: \$web"
echo ""

# Verificar se está logado
if ! az account show &> /dev/null; then
    echo "❌ Você não está logado no Azure. Execute 'az login' primeiro."
    exit 1
fi

# Obter storage key
log "Obtendo credenciais do Storage Account..."
STORAGE_KEY=$(az storage account keys list \
    --account-name "${STORAGE_ACCOUNT_NAME}" \
    --resource-group "${RG_NAME}" \
    --query "[0].value" \
    --output tsv)

# Upload de arquivos HTML
log "Uploading arquivos HTML..."
az storage blob upload-batch \
    --account-name "${STORAGE_ACCOUNT_NAME}" \
    --account-key "${STORAGE_KEY}" \
    --destination '$web' \
    --source . \
    --pattern "*.html" \
    --content-type "text/html; charset=utf-8" \
    --content-cache-control "public, max-age=3600" \
    --overwrite \
    --output none

# Upload de arquivos CSS
log "Uploading arquivos CSS..."
az storage blob upload-batch \
    --account-name "${STORAGE_ACCOUNT_NAME}" \
    --account-key "${STORAGE_KEY}" \
    --destination '$web' \
    --source ./css \
    --destination-path css \
    --pattern "*.css" \
    --content-type "text/css; charset=utf-8" \
    --content-cache-control "public, max-age=31536000" \
    --overwrite \
    --output none

# Upload de arquivos JS
log "Uploading arquivos JavaScript..."
az storage blob upload-batch \
    --account-name "${STORAGE_ACCOUNT_NAME}" \
    --account-key "${STORAGE_KEY}" \
    --destination '$web' \
    --source ./js \
    --destination-path js \
    --pattern "*.js" \
    --content-type "application/javascript; charset=utf-8" \
    --content-cache-control "public, max-age=31536000" \
    --overwrite \
    --output none

# Upload de imagens (se existir)
if [ -d "assets" ]; then
    log "Uploading assets..."
    az storage blob upload-batch \
        --account-name "${STORAGE_ACCOUNT_NAME}" \
        --account-key "${STORAGE_KEY}" \
        --destination '$web' \
        --source ./assets \
        --destination-path assets \
        --content-cache-control "public, max-age=31536000" \
        --overwrite \
        --output none
fi

# Purge Front Door cache (se configurado)
if az afd profile show --profile-name "${FRONTDOOR_NAME}" --resource-group "${RG_NAME}" &> /dev/null; then
    log "Purgando cache do Front Door..."
    az afd endpoint purge \
        --resource-group "${RG_NAME}" \
        --profile-name "${FRONTDOOR_NAME}" \
        --endpoint-name "${FRONTDOOR_ENDPOINT_NAME}" \
        --content-paths "/*" \
        --output none || info "Front Door purge falhou (pode não estar configurado ainda)"
fi

# Obter URL do website
STORAGE_WEB_ENDPOINT=$(az storage account show \
    --name "${STORAGE_ACCOUNT_NAME}" \
    --resource-group "${RG_NAME}" \
    --query "primaryEndpoints.web" \
    --output tsv)

echo ""
echo "=========================================="
echo "✅ DEPLOY CONCLUÍDO COM SUCESSO"
echo "=========================================="
echo ""
info "Website disponível em:"
echo "  • Storage: ${STORAGE_WEB_ENDPOINT}"
if [ ! -z "${FRONTDOOR_HOSTNAME:-}" ]; then
    echo "  • Front Door: https://${FRONTDOOR_HOSTNAME}"
fi
echo ""
log "Próximos passos:"
echo "  1. Testar o website nos URLs acima"
echo "  2. Configurar Front Door origins (se ainda não feito)"
echo "  3. Configurar custom domain e SSL"
echo ""
