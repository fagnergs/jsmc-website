#!/bin/bash
# provision-all.sh - Script completo de provisionamento Azure
# 
# Este script cria toda a infraestrutura Azure necessária para o site JSMC
# 
# PRÉ-REQUISITOS:
# 1. Azure CLI instalado e configurado (az --version)
# 2. Autenticação feita (az login)
# 3. Arquivo azure-config.sh configurado
#
# USO:
#   source azure-config.sh
#   chmod +x provision-all.sh
#   ./provision-all.sh

set -e  # Exit on error
set -u  # Exit on undefined variable

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função de log
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Carregar configurações
if [ ! -f "azure-config.sh" ]; then
    error "Arquivo azure-config.sh não encontrado! Execute 'source azure-config.sh' primeiro."
fi

source ./azure-config.sh

# Verificar se está logado no Azure
if ! az account show &> /dev/null; then
    error "Você não está logado no Azure. Execute 'az login' primeiro."
fi

# Confirmar execução
echo ""
echo "=========================================="
echo "JSMC Website - Provisionamento Azure"
echo "=========================================="
echo ""
echo "Este script criará os seguintes recursos:"
echo "  • Resource Group: ${RG_NAME}"
echo "  • Storage Account: ${STORAGE_ACCOUNT_NAME}"
echo "  • Front Door: ${FRONTDOOR_NAME}"
echo "  • Function App: ${FUNCTION_APP_NAME}"
echo "  • Key Vault: ${KEYVAULT_NAME}"
echo "  • Application Insights: ${APPINSIGHTS_NAME}"
echo "  • Log Analytics: ${LOG_WORKSPACE_NAME}"
echo "  • DNS Zone: ${DNS_ZONE_NAME}"
echo ""
echo "Subscription: ${AZURE_SUBSCRIPTION}"
echo "Location: ${AZURE_LOCATION}"
echo ""
read -p "Continuar? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operação cancelada pelo usuário."
    exit 1
fi

# Definir subscription
log "Configurando subscription..."
az account set --subscription "${AZURE_SUBSCRIPTION}" || error "Falha ao definir subscription"

# ===========================================
# 1. RESOURCE GROUP
# ===========================================
log "1/9 - Criando Resource Group..."
if az group show --name "${RG_NAME}" &> /dev/null; then
    warn "Resource Group ${RG_NAME} já existe. Pulando..."
else
    az group create \
        --name "${RG_NAME}" \
        --location "${AZURE_LOCATION}" \
        --tags ${TAGS} \
        --output none || error "Falha ao criar Resource Group"
    log "✅ Resource Group criado"
fi

# ===========================================
# 2. STORAGE ACCOUNT
# ===========================================
log "2/9 - Criando Storage Account..."
if az storage account show --name "${STORAGE_ACCOUNT_NAME}" --resource-group "${RG_NAME}" &> /dev/null; then
    warn "Storage Account ${STORAGE_ACCOUNT_NAME} já existe. Pulando..."
else
    az storage account create \
        --name "${STORAGE_ACCOUNT_NAME}" \
        --resource-group "${RG_NAME}" \
        --location "${AZURE_LOCATION}" \
        --sku "${STORAGE_SKU}" \
        --kind StorageV2 \
        --access-tier Hot \
        --https-only true \
        --min-tls-version TLS1_2 \
        --allow-blob-public-access true \
        --tags ${TAGS} \
        --output none || error "Falha ao criar Storage Account"
    
    # Habilitar Static Website
    az storage blob service-properties update \
        --account-name "${STORAGE_ACCOUNT_NAME}" \
        --static-website \
        --404-document 404.html \
        --index-document index.html \
        --output none || error "Falha ao habilitar Static Website"
    
    log "✅ Storage Account criado e configurado"
fi

# Obter endpoint do static website
STORAGE_WEB_ENDPOINT=$(az storage account show \
    --name "${STORAGE_ACCOUNT_NAME}" \
    --resource-group "${RG_NAME}" \
    --query "primaryEndpoints.web" \
    --output tsv)
info "Storage Web Endpoint: ${STORAGE_WEB_ENDPOINT}"

# ===========================================
# 3. FRONT DOOR PROFILE
# ===========================================
log "3/9 - Criando Azure Front Door Profile..."
if az afd profile show --profile-name "${FRONTDOOR_NAME}" --resource-group "${RG_NAME}" &> /dev/null; then
    warn "Front Door Profile ${FRONTDOOR_NAME} já existe. Pulando..."
else
    az afd profile create \
        --profile-name "${FRONTDOOR_NAME}" \
        --resource-group "${RG_NAME}" \
        --sku "${FRONTDOOR_SKU}" \
        --tags ${TAGS} \
        --output none || error "Falha ao criar Front Door Profile"
    log "✅ Front Door Profile criado"
fi

# Criar endpoint
log "3b/9 - Criando Front Door Endpoint..."
if az afd endpoint show --endpoint-name "${FRONTDOOR_ENDPOINT_NAME}" --profile-name "${FRONTDOOR_NAME}" --resource-group "${RG_NAME}" &> /dev/null; then
    warn "Front Door Endpoint já existe. Pulando..."
else
    az afd endpoint create \
        --resource-group "${RG_NAME}" \
        --profile-name "${FRONTDOOR_NAME}" \
        --endpoint-name "${FRONTDOOR_ENDPOINT_NAME}" \
        --enabled-state Enabled \
        --output none || error "Falha ao criar Front Door Endpoint"
    log "✅ Front Door Endpoint criado"
fi

FRONTDOOR_HOSTNAME=$(az afd endpoint show \
    --resource-group "${RG_NAME}" \
    --profile-name "${FRONTDOOR_NAME}" \
    --endpoint-name "${FRONTDOOR_ENDPOINT_NAME}" \
    --query "hostName" \
    --output tsv)
info "Front Door Endpoint: https://${FRONTDOOR_HOSTNAME}"

# ===========================================
# 4. FUNCTION STORAGE
# ===========================================
log "4/9 - Criando Storage para Functions..."
if az storage account show --name "${FUNCTION_STORAGE_NAME}" --resource-group "${RG_NAME}" &> /dev/null; then
    warn "Function Storage ${FUNCTION_STORAGE_NAME} já existe. Pulando..."
else
    az storage account create \
        --name "${FUNCTION_STORAGE_NAME}" \
        --resource-group "${RG_NAME}" \
        --location "${AZURE_LOCATION}" \
        --sku Standard_LRS \
        --kind StorageV2 \
        --https-only true \
        --tags ${TAGS} \
        --output none || error "Falha ao criar Function Storage"
    log "✅ Function Storage criado"
fi

# ===========================================
# 5. APPLICATION INSIGHTS
# ===========================================
log "5/9 - Criando Application Insights..."
if az monitor app-insights component show --app "${APPINSIGHTS_NAME}" --resource-group "${RG_NAME}" &> /dev/null; then
    warn "Application Insights ${APPINSIGHTS_NAME} já existe. Pulando..."
else
    az monitor app-insights component create \
        --app "${APPINSIGHTS_NAME}" \
        --location "${AZURE_LOCATION}" \
        --resource-group "${RG_NAME}" \
        --application-type web \
        --kind web \
        --tags ${TAGS} \
        --output none || error "Falha ao criar Application Insights"
    log "✅ Application Insights criado"
fi

APPINSIGHTS_KEY=$(az monitor app-insights component show \
    --app "${APPINSIGHTS_NAME}" \
    --resource-group "${RG_NAME}" \
    --query "instrumentationKey" \
    --output tsv)

# ===========================================
# 6. FUNCTION APP
# ===========================================
log "6/9 - Criando Function App..."
if az functionapp show --name "${FUNCTION_APP_NAME}" --resource-group "${RG_NAME}" &> /dev/null; then
    warn "Function App ${FUNCTION_APP_NAME} já existe. Pulando..."
else
    az functionapp create \
        --name "${FUNCTION_APP_NAME}" \
        --resource-group "${RG_NAME}" \
        --storage-account "${FUNCTION_STORAGE_NAME}" \
        --consumption-plan-location "${AZURE_LOCATION}" \
        --runtime "${FUNCTION_RUNTIME}" \
        --runtime-version "${FUNCTION_RUNTIME_VERSION}" \
        --functions-version 4 \
        --app-insights "${APPINSIGHTS_NAME}" \
        --app-insights-key "${APPINSIGHTS_KEY}" \
        --https-only true \
        --tags ${TAGS} \
        --output none || error "Falha ao criar Function App"
    
    # Configurar CORS
    az functionapp cors add \
        --name "${FUNCTION_APP_NAME}" \
        --resource-group "${RG_NAME}" \
        --allowed-origins "https://${CUSTOM_DOMAIN}" "https://${CUSTOM_DOMAIN_WWW}" \
        --output none || warn "Falha ao configurar CORS"
    
    log "✅ Function App criado"
fi

# ===========================================
# 7. KEY VAULT
# ===========================================
log "7/9 - Criando Key Vault..."
if az keyvault show --name "${KEYVAULT_NAME}" --resource-group "${RG_NAME}" &> /dev/null; then
    warn "Key Vault ${KEYVAULT_NAME} já existe. Pulando..."
else
    az keyvault create \
        --name "${KEYVAULT_NAME}" \
        --resource-group "${RG_NAME}" \
        --location "${AZURE_LOCATION}" \
        --sku standard \
        --enabled-for-deployment false \
        --enabled-for-disk-encryption false \
        --enabled-for-template-deployment true \
        --tags ${TAGS} \
        --output none || error "Falha ao criar Key Vault"
    
    # Dar acesso à Function App
    FUNCTION_PRINCIPAL_ID=$(az functionapp identity assign \
        --name "${FUNCTION_APP_NAME}" \
        --resource-group "${RG_NAME}" \
        --query "principalId" \
        --output tsv)
    
    az keyvault set-policy \
        --name "${KEYVAULT_NAME}" \
        --resource-group "${RG_NAME}" \
        --object-id "${FUNCTION_PRINCIPAL_ID}" \
        --secret-permissions get list \
        --output none || warn "Falha ao configurar Key Vault policy"
    
    log "✅ Key Vault criado e configurado"
fi

# ===========================================
# 8. LOG ANALYTICS
# ===========================================
log "8/9 - Criando Log Analytics Workspace..."
if az monitor log-analytics workspace show --workspace-name "${LOG_WORKSPACE_NAME}" --resource-group "${RG_NAME}" &> /dev/null; then
    warn "Log Analytics ${LOG_WORKSPACE_NAME} já existe. Pulando..."
else
    az monitor log-analytics workspace create \
        --resource-group "${RG_NAME}" \
        --workspace-name "${LOG_WORKSPACE_NAME}" \
        --location "${AZURE_LOCATION}" \
        --retention-time 30 \
        --tags ${TAGS} \
        --output none || error "Falha ao criar Log Analytics"
    log "✅ Log Analytics Workspace criado"
fi

# ===========================================
# 9. DNS ZONE
# ===========================================
log "9/9 - Criando DNS Zone..."
if az network dns zone show --name "${DNS_ZONE_NAME}" --resource-group "${RG_NAME}" &> /dev/null; then
    warn "DNS Zone ${DNS_ZONE_NAME} já existe. Pulando..."
else
    az network dns zone create \
        --resource-group "${RG_NAME}" \
        --name "${DNS_ZONE_NAME}" \
        --tags ${TAGS} \
        --output none || error "Falha ao criar DNS Zone"
    log "✅ DNS Zone criado"
fi

# Obter Name Servers
NAME_SERVERS=$(az network dns zone show \
    --resource-group "${RG_NAME}" \
    --name "${DNS_ZONE_NAME}" \
    --query "nameServers" \
    --output tsv)

# ===========================================
# RESUMO
# ===========================================
echo ""
echo "=========================================="
echo "✅ PROVISIONAMENTO CONCLUÍDO COM SUCESSO"
echo "=========================================="
echo ""
log "Recursos criados:"
echo "  ✓ Resource Group: ${RG_NAME}"
echo "  ✓ Storage Account: ${STORAGE_ACCOUNT_NAME}"
echo "    └─ Web Endpoint: ${STORAGE_WEB_ENDPOINT}"
echo "  ✓ Front Door: ${FRONTDOOR_NAME}"
echo "    └─ Endpoint: https://${FRONTDOOR_HOSTNAME}"
echo "  ✓ Function App: ${FUNCTION_APP_NAME}"
echo "  ✓ Key Vault: ${KEYVAULT_NAME}"
echo "  ✓ Application Insights: ${APPINSIGHTS_NAME}"
echo "  ✓ Log Analytics: ${LOG_WORKSPACE_NAME}"
echo "  ✓ DNS Zone: ${DNS_ZONE_NAME}"
echo ""
log "Name Servers para configurar no registrador:"
echo "${NAME_SERVERS}"
echo ""
log "Próximos passos:"
echo "  1. Configurar Front Door origins e routes (ver AZURE-INFRASTRUCTURE-GUIDE.md)"
echo "  2. Upload website: ./deploy-website.sh"
echo "  3. Configurar custom domain e SSL"
echo "  4. Deploy Azure Functions"
echo "  5. Configurar GitHub Actions secrets"
echo ""
log "Tempo estimado para próximos passos: 30-45 minutos"
echo ""
