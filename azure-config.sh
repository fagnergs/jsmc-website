#!/bin/bash
# azure-config.sh - Configurações da infraestrutura JSMC Azure
# 
# INSTRUÇÕES DE USO:
# 1. Edite as variáveis abaixo conforme seu ambiente Azure
# 2. Execute: source azure-config.sh
# 3. Execute: ./provision-all.sh

set -a  # Exportar todas as variáveis automaticamente

# === CONFIGURAÇÕES GLOBAIS ===
AZURE_SUBSCRIPTION="JSMC-Production"  # Nome ou ID da sua subscription
AZURE_LOCATION="brazilsouth"  # São Paulo (recomendado)
AZURE_LOCATION_SECONDARY="eastus2"  # Backup/DR

# === NAMING CONVENTIONS ===
PROJECT_NAME="jsmc"
ENVIRONMENT="prod"
RESOURCE_PREFIX="${PROJECT_NAME}-${ENVIRONMENT}"

# === RESOURCE GROUP ===
RG_NAME="rg-${PROJECT_NAME}-website-${ENVIRONMENT}"

# === STORAGE ACCOUNT ===
# IMPORTANTE: Nome deve ser único globalmente, apenas letras minúsculas e números
STORAGE_ACCOUNT_NAME="jsmcwebsite${ENVIRONMENT}"  # Altere se necessário
STORAGE_SKU="Standard_LRS"
STORAGE_CONTAINER_WEB='$web'

# === FRONT DOOR ===
FRONTDOOR_NAME="fd-${PROJECT_NAME}-website-${ENVIRONMENT}"
FRONTDOOR_SKU="Premium_AzureFrontDoor"  # Inclui WAF
FRONTDOOR_ENDPOINT_NAME="${PROJECT_NAME}-website"

# === FUNCTION APP ===
FUNCTION_APP_NAME="func-${PROJECT_NAME}-contact-${ENVIRONMENT}"
FUNCTION_STORAGE_NAME="${PROJECT_NAME}funcstore${ENVIRONMENT}"
FUNCTION_RUNTIME="node"
FUNCTION_RUNTIME_VERSION="18"

# === KEY VAULT ===
# IMPORTANTE: Nome deve ser único globalmente
KEYVAULT_NAME="kv-${PROJECT_NAME}-web-${ENVIRONMENT}"

# === DNS ===
DNS_ZONE_NAME="jsmc.com.br"
CUSTOM_DOMAIN="jsmc.com.br"
CUSTOM_DOMAIN_WWW="www.jsmc.com.br"

# === APPLICATION INSIGHTS ===
APPINSIGHTS_NAME="appi-${PROJECT_NAME}-website-${ENVIRONMENT}"

# === LOG ANALYTICS ===
LOG_WORKSPACE_NAME="law-${PROJECT_NAME}-website-${ENVIRONMENT}"

# === TAGS (Obrigatórios para FinOps) ===
TAG_ENVIRONMENT="${ENVIRONMENT}"
TAG_PROJECT="JSMC-Website"
TAG_MANAGED_BY="Azure-CLI"
TAG_COST_CENTER="JSMC-Marketing"
TAG_OWNER="JSMC-IT"

TAGS="Environment=${TAG_ENVIRONMENT} Project=${TAG_PROJECT} ManagedBy=${TAG_MANAGED_BY} CostCenter=${TAG_COST_CENTER} Owner=${TAG_OWNER}"

# === BUDGET ===
BUDGET_AMOUNT=30  # USD per month
BUDGET_ALERT_EMAIL="informacoes@jsmc.com.br"

# === SENDGRID ===
# Configurar após criar conta SendGrid no marketplace
# SENDGRID_API_KEY será armazenado no Key Vault

set +a  # Desativar exportação automática

# === VALIDAÇÃO ===
echo ""
echo "=========================================="
echo "JSMC Azure - Configurações Carregadas"
echo "=========================================="
echo ""
echo "📦 Subscription:       ${AZURE_SUBSCRIPTION}"
echo "📍 Location:           ${AZURE_LOCATION}"
echo "📂 Resource Group:     ${RG_NAME}"
echo "💾 Storage Account:    ${STORAGE_ACCOUNT_NAME}"
echo "🌐 Front Door:         ${FRONTDOOR_NAME}"
echo "⚡ Function App:       ${FUNCTION_APP_NAME}"
echo "🔐 Key Vault:          ${KEYVAULT_NAME}"
echo "🌍 DNS Zone:           ${DNS_ZONE_NAME}"
echo ""
echo "✅ Configurações prontas!"
echo ""
echo "Próximos passos:"
echo "  1. Revisar variáveis acima"
echo "  2. Fazer az login"
echo "  3. Executar: ./provision-all.sh"
echo ""
