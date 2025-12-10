# 🔧 GUIA DE INFRAESTRUTURA AZURE - Comandos CLI

<div align="center">

**Provisionamento Completo da Infraestrutura Azure via CLI**

[![Azure CLI](https://img.shields.io/badge/Azure%20CLI-2.50+-0078D4.svg)](https://docs.microsoft.com/cli/azure/)
[![Bash](https://img.shields.io/badge/Shell-Bash-4EAA25.svg)](https://www.gnu.org/software/bash/)

</div>

---

## 📋 Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Configuração Inicial](#configuração-inicial)
3. [Provisionamento Passo-a-Passo](#provisionamento-passo-a-passo)
4. [Scripts Automatizados](#scripts-automatizados)
5. [Validação](#validação)
6. [Troubleshooting](#troubleshooting)

---

## ✅ Pré-requisitos

### Software Necessário

```bash
# Azure CLI
az --version
# Required: >= 2.50.0

# Se não instalado:
# macOS: brew install azure-cli
# Windows: winget install -e --id Microsoft.AzureCLI
# Linux: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Outras ferramentas úteis
jq --version      # JSON processor
git --version     # Version control
```

### Autenticação Azure

```bash
# Login interativo
az login

# Ou via Service Principal (CI/CD)
az login --service-principal \
  --username $AZURE_CLIENT_ID \
  --password $AZURE_CLIENT_SECRET \
  --tenant $AZURE_TENANT_ID

# Verificar login
az account show

# Listar subscriptions
az account list --output table

# Definir subscription padrão
az account set --subscription "JSMC-Production"
```

---

## ⚙️ Configuração Inicial

### Variáveis de Ambiente

Crie um arquivo `azure-config.sh` com as variáveis:

```bash
#!/bin/bash
# azure-config.sh - Configurações da infraestrutura JSMC Azure

# === CONFIGURAÇÕES GLOBAIS ===
export AZURE_SUBSCRIPTION="JSMC-Production"
export AZURE_LOCATION="brazilsouth"  # São Paulo
export AZURE_LOCATION_SECONDARY="eastus2"  # Backup

# === NAMING ===
export PROJECT_NAME="jsmc"
export ENVIRONMENT="prod"
export RESOURCE_PREFIX="${PROJECT_NAME}-${ENVIRONMENT}"

# === RESOURCE GROUP ===
export RG_NAME="rg-${PROJECT_NAME}-website-${ENVIRONMENT}"

# === STORAGE ACCOUNT ===
export STORAGE_ACCOUNT_NAME="jsmcwebsite${ENVIRONMENT}"  # Sem hífens, max 24 chars
export STORAGE_SKU="Standard_LRS"
export STORAGE_CONTAINER_WEB='$web'

# === FRONT DOOR ===
export FRONTDOOR_NAME="fd-${PROJECT_NAME}-website-${ENVIRONMENT}"
export FRONTDOOR_SKU="Premium_AzureFrontDoor"  # Inclui WAF

# === FUNCTION APP ===
export FUNCTION_APP_NAME="func-${PROJECT_NAME}-contact-${ENVIRONMENT}"
export FUNCTION_STORAGE_NAME="${PROJECT_NAME}funcstore${ENVIRONMENT}"
export FUNCTION_RUNTIME="node"
export FUNCTION_RUNTIME_VERSION="18"

# === KEY VAULT ===
export KEYVAULT_NAME="kv-${PROJECT_NAME}-web-${ENVIRONMENT}"

# === DNS ===
export DNS_ZONE_NAME="jsmc.com.br"
export CUSTOM_DOMAIN="jsmc.com.br"
export CUSTOM_DOMAIN_WWW="www.jsmc.com.br"

# === APPLICATION INSIGHTS ===
export APPINSIGHTS_NAME="appi-${PROJECT_NAME}-website-${ENVIRONMENT}"

# === LOG ANALYTICS ===
export LOG_WORKSPACE_NAME="law-${PROJECT_NAME}-website-${ENVIRONMENT}"

# === TAGS ===
export TAGS="Environment=${ENVIRONMENT} Project=JSMC-Website ManagedBy=CLI CostCenter=JSMC-Marketing Owner=JSMC-IT"

# === BUDGET ===
export BUDGET_AMOUNT=30  # USD per month
export BUDGET_ALERT_EMAIL="informacoes@jsmc.com.br"

echo "✅ Configurações carregadas:"
echo "   Subscription: $AZURE_SUBSCRIPTION"
echo "   Location: $AZURE_LOCATION"
echo "   Resource Group: $RG_NAME"
echo "   Storage Account: $STORAGE_ACCOUNT_NAME"
```

**Uso:**

```bash
# Carregar configurações
source azure-config.sh

# Ou adicionar ao ~/.bashrc ou ~/.zshrc
echo 'source /path/to/azure-config.sh' >> ~/.bashrc
```

---

## 🚀 Provisionamento Passo-a-Passo

### Passo 1: Resource Group

```bash
# Criar Resource Group
az group create \
  --name $RG_NAME \
  --location $AZURE_LOCATION \
  --tags $TAGS

# Verificar
az group show --name $RG_NAME --output table

# Listar resources (deve estar vazio)
az resource list --resource-group $RG_NAME --output table
```

### Passo 2: Storage Account (Static Website)

```bash
# Criar Storage Account
az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RG_NAME \
  --location $AZURE_LOCATION \
  --sku $STORAGE_SKU \
  --kind StorageV2 \
  --access-tier Hot \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access true \
  --tags $TAGS

# Habilitar Static Website
az storage blob service-properties update \
  --account-name $STORAGE_ACCOUNT_NAME \
  --static-website \
  --404-document 404.html \
  --index-document index.html

# Obter endpoint do static website
export STORAGE_WEB_ENDPOINT=$(az storage account show \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RG_NAME \
  --query "primaryEndpoints.web" \
  --output tsv)

echo "Storage Web Endpoint: $STORAGE_WEB_ENDPOINT"

# Verificar
az storage account show \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RG_NAME \
  --output table
```

### Passo 3: Upload Inicial (Teste)

```bash
# Obter connection string
export STORAGE_CONNECTION_STRING=$(az storage account show-connection-string \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RG_NAME \
  --output tsv)

# Upload de teste (arquivo HTML simples)
echo "<html><body><h1>JSMC - Azure Test</h1></body></html>" > test.html

az storage blob upload \
  --account-name $STORAGE_ACCOUNT_NAME \
  --container-name '$web' \
  --name index.html \
  --file test.html \
  --content-type "text/html" \
  --overwrite

# Testar acesso
curl $STORAGE_WEB_ENDPOINT
# Deve retornar: <html><body><h1>JSMC - Azure Test</h1></body></html>

# Limpar arquivo teste
rm test.html
```

### Passo 4: Azure Front Door

```bash
# Criar Front Door Profile
az afd profile create \
  --profile-name $FRONTDOOR_NAME \
  --resource-group $RG_NAME \
  --sku $FRONTDOOR_SKU \
  --tags $TAGS

# Criar Endpoint
export FRONTDOOR_ENDPOINT_NAME="${PROJECT_NAME}-website"

az afd endpoint create \
  --resource-group $RG_NAME \
  --profile-name $FRONTDOOR_NAME \
  --endpoint-name $FRONTDOOR_ENDPOINT_NAME \
  --enabled-state Enabled

# Obter endpoint hostname
export FRONTDOOR_HOSTNAME=$(az afd endpoint show \
  --resource-group $RG_NAME \
  --profile-name $FRONTDOOR_NAME \
  --endpoint-name $FRONTDOOR_ENDPOINT_NAME \
  --query "hostName" \
  --output tsv)

echo "Front Door Endpoint: https://$FRONTDOOR_HOSTNAME"

# Criar Origin Group
export ORIGIN_GROUP_NAME="storage-origin-group"

az afd origin-group create \
  --resource-group $RG_NAME \
  --profile-name $FRONTDOOR_NAME \
  --origin-group-name $ORIGIN_GROUP_NAME \
  --probe-request-type GET \
  --probe-protocol Https \
  --probe-interval-in-seconds 100 \
  --probe-path "/" \
  --sample-size 4 \
  --successful-samples-required 3 \
  --additional-latency-in-milliseconds 50

# Criar Origin (Storage Account)
export ORIGIN_NAME="storage-origin"
export STORAGE_HOST=$(echo $STORAGE_WEB_ENDPOINT | sed 's|https://||' | sed 's|/||')

az afd origin create \
  --resource-group $RG_NAME \
  --profile-name $FRONTDOOR_NAME \
  --origin-group-name $ORIGIN_GROUP_NAME \
  --origin-name $ORIGIN_NAME \
  --origin-host-header $STORAGE_HOST \
  --host-name $STORAGE_HOST \
  --http-port 80 \
  --https-port 443 \
  --priority 1 \
  --weight 1000 \
  --enabled-state Enabled

# Criar Route
export ROUTE_NAME="default-route"

az afd route create \
  --resource-group $RG_NAME \
  --profile-name $FRONTDOOR_NAME \
  --endpoint-name $FRONTDOOR_ENDPOINT_NAME \
  --route-name $ROUTE_NAME \
  --origin-group $ORIGIN_GROUP_NAME \
  --supported-protocols Http Https \
  --https-redirect Enabled \
  --forwarding-protocol HttpsOnly \
  --link-to-default-domain Enabled \
  --patterns-to-match "/*" \
  --enable-caching true \
  --query-string-caching-behavior UseQueryString \
  --compression-settings isCompressionEnabled=true contentTypesToCompress=text/html,text/css,application/javascript,application/json

# Testar Front Door
echo "Aguarde 2-5 minutos para propagação..."
sleep 120
curl -I https://$FRONTDOOR_HOSTNAME
```

### Passo 5: Custom Domain e SSL

```bash
# Criar DNS Zone (se não existir)
az network dns zone create \
  --resource-group $RG_NAME \
  --name $DNS_ZONE_NAME \
  --tags $TAGS

# Obter Name Servers
az network dns zone show \
  --resource-group $RG_NAME \
  --name $DNS_ZONE_NAME \
  --query "nameServers" \
  --output tsv

echo "Configure estes Name Servers no seu registrador de domínio:"
echo "Isso pode levar 24-48h para propagar"

# Adicionar custom domain ao Front Door (após DNS propagar)
az afd custom-domain create \
  --resource-group $RG_NAME \
  --profile-name $FRONTDOOR_NAME \
  --custom-domain-name jsmc-com-br \
  --host-name $CUSTOM_DOMAIN \
  --minimum-tls-version TLS12 \
  --certificate-type ManagedCertificate

# Adicionar www
az afd custom-domain create \
  --resource-group $RG_NAME \
  --profile-name $FRONTDOOR_NAME \
  --custom-domain-name www-jsmc-com-br \
  --host-name $CUSTOM_DOMAIN_WWW \
  --minimum-tls-version TLS12 \
  --certificate-type ManagedCertificate

# Validar domínio (obter TXT record)
az afd custom-domain show \
  --resource-group $RG_NAME \
  --profile-name $FRONTDOOR_NAME \
  --custom-domain-name jsmc-com-br \
  --query "validationProperties"

# Adicionar TXT record no DNS
# _dnsauth.jsmc.com.br → valor retornado acima

# Associar custom domain à route
az afd route update \
  --resource-group $RG_NAME \
  --profile-name $FRONTDOOR_NAME \
  --endpoint-name $FRONTDOOR_ENDPOINT_NAME \
  --route-name $ROUTE_NAME \
  --custom-domains jsmc-com-br www-jsmc-com-br
```

### Passo 6: Azure Functions (Formulário)

```bash
# Criar Storage Account para Functions
az storage account create \
  --name $FUNCTION_STORAGE_NAME \
  --resource-group $RG_NAME \
  --location $AZURE_LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --https-only true \
  --tags $TAGS

# Criar Application Insights
az monitor app-insights component create \
  --app $APPINSIGHTS_NAME \
  --location $AZURE_LOCATION \
  --resource-group $RG_NAME \
  --application-type web \
  --kind web \
  --tags $TAGS

# Obter Instrumentation Key
export APPINSIGHTS_KEY=$(az monitor app-insights component show \
  --app $APPINSIGHTS_NAME \
  --resource-group $RG_NAME \
  --query "instrumentationKey" \
  --output tsv)

# Criar Function App
az functionapp create \
  --name $FUNCTION_APP_NAME \
  --resource-group $RG_NAME \
  --storage-account $FUNCTION_STORAGE_NAME \
  --consumption-plan-location $AZURE_LOCATION \
  --runtime $FUNCTION_RUNTIME \
  --runtime-version $FUNCTION_RUNTIME_VERSION \
  --functions-version 4 \
  --app-insights $APPINSIGHTS_NAME \
  --app-insights-key $APPINSIGHTS_KEY \
  --https-only true \
  --tags $TAGS

# Configurar CORS
az functionapp cors add \
  --name $FUNCTION_APP_NAME \
  --resource-group $RG_NAME \
  --allowed-origins "https://$CUSTOM_DOMAIN" "https://$CUSTOM_DOMAIN_WWW"

# Configurar variáveis de ambiente (placeholders)
az functionapp config appsettings set \
  --name $FUNCTION_APP_NAME \
  --resource-group $RG_NAME \
  --settings \
    "FROM_EMAIL=informacoes@jsmc.com.br" \
    "TO_EMAIL=informacoes@jsmc.com.br" \
    "ENVIRONMENT=production"

# Deploy será feito via GitHub Actions ou manual
```

### Passo 7: Key Vault (Secrets)

```bash
# Criar Key Vault
az keyvault create \
  --name $KEYVAULT_NAME \
  --resource-group $RG_NAME \
  --location $AZURE_LOCATION \
  --sku standard \
  --enabled-for-deployment false \
  --enabled-for-disk-encryption false \
  --enabled-for-template-deployment true \
  --tags $TAGS

# Dar acesso à Function App
export FUNCTION_PRINCIPAL_ID=$(az functionapp identity assign \
  --name $FUNCTION_APP_NAME \
  --resource-group $RG_NAME \
  --query "principalId" \
  --output tsv)

az keyvault set-policy \
  --name $KEYVAULT_NAME \
  --resource-group $RG_NAME \
  --object-id $FUNCTION_PRINCIPAL_ID \
  --secret-permissions get list

# Adicionar secret SendGrid (placeholder - será adicionado depois)
# az keyvault secret set \
#   --vault-name $KEYVAULT_NAME \
#   --name sendgrid-api-key \
#   --value "SG.xxxxxxxxxxxxx"

# Obter Key Vault URI
export KEYVAULT_URI=$(az keyvault show \
  --name $KEYVAULT_NAME \
  --resource-group $RG_NAME \
  --query "properties.vaultUri" \
  --output tsv)

echo "Key Vault URI: $KEYVAULT_URI"
```

### Passo 8: Log Analytics e Monitoring

```bash
# Criar Log Analytics Workspace
az monitor log-analytics workspace create \
  --resource-group $RG_NAME \
  --workspace-name $LOG_WORKSPACE_NAME \
  --location $AZURE_LOCATION \
  --retention-time 30 \
  --tags $TAGS

# Obter Workspace ID
export WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group $RG_NAME \
  --workspace-name $LOG_WORKSPACE_NAME \
  --query "customerId" \
  --output tsv)

# Conectar Application Insights ao Log Analytics
az monitor app-insights component update \
  --app $APPINSIGHTS_NAME \
  --resource-group $RG_NAME \
  --workspace $WORKSPACE_ID

# Criar Action Group para alertas
az monitor action-group create \
  --name "ag-jsmc-website-alerts" \
  --resource-group $RG_NAME \
  --short-name "jsmc-alert" \
  --email-receiver name="Admin" email-address="$BUDGET_ALERT_EMAIL"

# Criar alerta de budget (80% threshold)
# Nota: Budget precisa ser criado via portal ou ARM template
# CLI não suporta completamente budgets ainda
```

### Passo 9: Service Principal (GitHub Actions)

```bash
# Criar Service Principal para GitHub Actions
export SP_NAME="sp-github-actions-jsmc-website"

# Obter subscription ID
export SUBSCRIPTION_ID=$(az account show --query "id" --output tsv)

# Criar SP e atribuir role
az ad sp create-for-rbac \
  --name $SP_NAME \
  --role Contributor \
  --scopes "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_NAME" \
  --sdk-auth

# Output será um JSON - salvar para configurar GitHub Secrets:
# {
#   "clientId": "xxx",
#   "clientSecret": "xxx",
#   "subscriptionId": "xxx",
#   "tenantId": "xxx",
#   ...
# }

echo "⚠️  IMPORTANTE: Salve o JSON acima em local seguro!"
echo "Será usado para configurar GitHub Secrets"

# Para OIDC (recomendado - sem secrets):
# Criar federated credential
az ad app federated-credential create \
  --id $SP_CLIENT_ID \
  --parameters '{
    "name": "github-jsmc-website",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:JSMC-Solucoes/website:ref:refs/heads/jsmc-azure",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

---

## 🤖 Scripts Automatizados

### Script Completo: provision-all.sh

```bash
#!/bin/bash
# provision-all.sh - Provisionar toda infraestrutura Azure

set -e  # Exit on error

# Carregar configurações
source ./azure-config.sh

echo "=========================================="
echo "JSMC Website - Provisionamento Azure"
echo "=========================================="
echo ""
echo "Subscription: $AZURE_SUBSCRIPTION"
echo "Resource Group: $RG_NAME"
echo "Location: $AZURE_LOCATION"
echo ""
read -p "Continuar? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# 1. Resource Group
echo ""
echo "1/9 - Criando Resource Group..."
az group create \
  --name $RG_NAME \
  --location $AZURE_LOCATION \
  --tags $TAGS \
  --output none
echo "✅ Resource Group criado"

# 2. Storage Account
echo ""
echo "2/9 - Criando Storage Account..."
az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RG_NAME \
  --location $AZURE_LOCATION \
  --sku $STORAGE_SKU \
  --kind StorageV2 \
  --access-tier Hot \
  --https-only true \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access true \
  --tags $TAGS \
  --output none

az storage blob service-properties update \
  --account-name $STORAGE_ACCOUNT_NAME \
  --static-website \
  --404-document 404.html \
  --index-document index.html \
  --output none
echo "✅ Storage Account criado"

# 3. Front Door
echo ""
echo "3/9 - Criando Azure Front Door..."
az afd profile create \
  --profile-name $FRONTDOOR_NAME \
  --resource-group $RG_NAME \
  --sku $FRONTDOOR_SKU \
  --tags $TAGS \
  --output none
echo "✅ Front Door criado"

# 4. Function Storage
echo ""
echo "4/9 - Criando Storage para Functions..."
az storage account create \
  --name $FUNCTION_STORAGE_NAME \
  --resource-group $RG_NAME \
  --location $AZURE_LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 \
  --https-only true \
  --tags $TAGS \
  --output none
echo "✅ Function Storage criado"

# 5. Application Insights
echo ""
echo "5/9 - Criando Application Insights..."
az monitor app-insights component create \
  --app $APPINSIGHTS_NAME \
  --location $AZURE_LOCATION \
  --resource-group $RG_NAME \
  --application-type web \
  --kind web \
  --tags $TAGS \
  --output none
echo "✅ Application Insights criado"

# 6. Function App
echo ""
echo "6/9 - Criando Function App..."
APPINSIGHTS_KEY=$(az monitor app-insights component show \
  --app $APPINSIGHTS_NAME \
  --resource-group $RG_NAME \
  --query "instrumentationKey" \
  --output tsv)

az functionapp create \
  --name $FUNCTION_APP_NAME \
  --resource-group $RG_NAME \
  --storage-account $FUNCTION_STORAGE_NAME \
  --consumption-plan-location $AZURE_LOCATION \
  --runtime $FUNCTION_RUNTIME \
  --runtime-version $FUNCTION_RUNTIME_VERSION \
  --functions-version 4 \
  --app-insights $APPINSIGHTS_NAME \
  --app-insights-key $APPINSIGHTS_KEY \
  --https-only true \
  --tags $TAGS \
  --output none
echo "✅ Function App criado"

# 7. Key Vault
echo ""
echo "7/9 - Criando Key Vault..."
az keyvault create \
  --name $KEYVAULT_NAME \
  --resource-group $RG_NAME \
  --location $AZURE_LOCATION \
  --sku standard \
  --enabled-for-deployment false \
  --enabled-for-disk-encryption false \
  --enabled-for-template-deployment true \
  --tags $TAGS \
  --output none
echo "✅ Key Vault criado"

# 8. Log Analytics
echo ""
echo "8/9 - Criando Log Analytics Workspace..."
az monitor log-analytics workspace create \
  --resource-group $RG_NAME \
  --workspace-name $LOG_WORKSPACE_NAME \
  --location $AZURE_LOCATION \
  --retention-time 30 \
  --tags $TAGS \
  --output none
echo "✅ Log Analytics Workspace criado"

# 9. DNS Zone
echo ""
echo "9/9 - Criando DNS Zone..."
az network dns zone create \
  --resource-group $RG_NAME \
  --name $DNS_ZONE_NAME \
  --tags $TAGS \
  --output none
echo "✅ DNS Zone criado"

# Resumo
echo ""
echo "=========================================="
echo "✅ PROVISIONAMENTO CONCLUÍDO"
echo "=========================================="
echo ""
echo "Recursos criados:"
echo "  - Resource Group: $RG_NAME"
echo "  - Storage Account: $STORAGE_ACCOUNT_NAME"
echo "  - Front Door: $FRONTDOOR_NAME"
echo "  - Function App: $FUNCTION_APP_NAME"
echo "  - Key Vault: $KEYVAULT_NAME"
echo "  - Application Insights: $APPINSIGHTS_NAME"
echo "  - Log Analytics: $LOG_WORKSPACE_NAME"
echo "  - DNS Zone: $DNS_ZONE_NAME"
echo ""
echo "Próximos passos:"
echo "  1. Configurar Front Door endpoints e routes"
echo "  2. Upload website para Storage Account"
echo "  3. Configurar Custom Domain e SSL"
echo "  4. Deploy Azure Functions"
echo "  5. Configurar GitHub Actions"
echo ""
```

### Script de Deploy: deploy-website.sh

```bash
#!/bin/bash
# deploy-website.sh - Deploy website para Azure Storage

set -e

source ./azure-config.sh

echo "Deploying website to Azure Storage..."
echo "Storage Account: $STORAGE_ACCOUNT_NAME"
echo ""

# Obter connection string
STORAGE_KEY=$(az storage account keys list \
  --account-name $STORAGE_ACCOUNT_NAME \
  --resource-group $RG_NAME \
  --query "[0].value" \
  --output tsv)

# Upload arquivos
az storage blob upload-batch \
  --account-name $STORAGE_ACCOUNT_NAME \
  --account-key $STORAGE_KEY \
  --destination '$web' \
  --source . \
  --pattern "*.html" --pattern "*.css" --pattern "*.js" \
  --pattern "*.jpg" --pattern "*.png" --pattern "*.svg" \
  --content-cache-control "public, max-age=3600" \
  --overwrite

# Purge Front Door cache
echo "Purging Front Door cache..."
az afd endpoint purge \
  --resource-group $RG_NAME \
  --profile-name $FRONTDOOR_NAME \
  --endpoint-name $FRONTDOOR_ENDPOINT_NAME \
  --content-paths "/*"

echo "✅ Deploy concluído!"
```

---

## ✅ Validação

### Checklist Pós-Provisionamento

```bash
# 1. Verificar Resource Group
az group show --name $RG_NAME --output table

# 2. Listar todos os recursos
az resource list --resource-group $RG_NAME --output table

# 3. Verificar Storage Account
az storage account show \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RG_NAME \
  --query "[name,primaryEndpoints.web]" \
  --output tsv

# 4. Testar Static Website
curl -I $(az storage account show \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RG_NAME \
  --query "primaryEndpoints.web" \
  --output tsv)

# 5. Verificar Front Door
az afd profile show \
  --resource-group $RG_NAME \
  --profile-name $FRONTDOOR_NAME \
  --output table

# 6. Verificar Function App
az functionapp show \
  --name $FUNCTION_APP_NAME \
  --resource-group $RG_NAME \
  --query "[name,state,defaultHostName]" \
  --output tsv

# 7. Verificar Key Vault
az keyvault show \
  --name $KEYVAULT_NAME \
  --resource-group $RG_NAME \
  --query "[name,properties.vaultUri]" \
  --output tsv

# 8. DNS Name Servers
az network dns zone show \
  --resource-group $RG_NAME \
  --name $DNS_ZONE_NAME \
  --query "nameServers" \
  --output table
```

---

## 🔧 Troubleshooting

### Problemas Comuns

#### 1. Nome de Storage Account já existe

```bash
# Erro: The storage account named 'jsmcwebsite' is already taken.

# Solução: Adicionar sufixo aleatório
export STORAGE_ACCOUNT_NAME="jsmcwebsite$(openssl rand -hex 3)"
echo "Novo nome: $STORAGE_ACCOUNT_NAME"
```

#### 2. Front Door provisioning failed

```bash
# Verificar status
az afd profile show \
  --resource-group $RG_NAME \
  --profile-name $FRONTDOOR_NAME \
  --query "provisioningState"

# Se falhou, deletar e recriar
az afd profile delete \
  --resource-group $RG_NAME \
  --profile-name $FRONTDOOR_NAME \
  --yes
```

#### 3. DNS não propaga

```bash
# Verificar nameservers
dig NS jsmc.com.br

# Verificar registro A
dig A jsmc.com.br

# Forçar resolver específico
dig @8.8.8.8 A jsmc.com.br
```

#### 4. Certificado SSL não provisiona

```bash
# Verificar validação do domínio
az afd custom-domain show \
  --resource-group $RG_NAME \
  --profile-name $FRONTDOOR_NAME \
  --custom-domain-name jsmc-com-br \
  --query "validationProperties"

# Verificar TXT record
dig TXT _dnsauth.jsmc.com.br
```

---

## 📞 Suporte

Para problemas ou dúvidas:

1. **Azure Documentation**: https://docs.microsoft.com/azure
2. **Azure CLI Reference**: https://docs.microsoft.com/cli/azure
3. **Azure Support**: Portal Azure > Help + Support
4. **GitHub Issues**: https://github.com/JSMC-Solucoes/website/issues

---

<div align="center">

**Guia criado em 10 de Dezembro de 2024**

**Versão 1.0.0**

[![Azure](https://img.shields.io/badge/Azure-Infrastructure-0078D4.svg)](https://azure.microsoft.com)
[![CLI](https://img.shields.io/badge/Azure%20CLI-2.50+-0078D4.svg)](https://docs.microsoft.com/cli/azure/)

**Preparado para JSMC Soluções**

</div>

---

**© 2024 JSMC Soluções. Documento Técnico.**
