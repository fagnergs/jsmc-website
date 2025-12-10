# 📧 Azure Functions - Contact Form Handler

Função Azure Functions para processar formulário de contato do website JSMC Soluções com SendGrid.

## 📁 Estrutura

```
azure-functions/
├── ContactFormHandler/
│   ├── index.js         # Handler principal
│   └── function.json    # Configuração do HTTP trigger
├── package.json         # Dependências Node.js
├── host.json           # Configuração do host Azure Functions
└── README.md           # Este arquivo
```

## 🚀 Deploy

### Opção 1: Deploy Manual via Azure CLI

```bash
cd azure-functions

# Instalar dependências
npm install

# Deploy para Azure Function App
func azure functionapp publish func-jsmc-contact-prod
```

### Opção 2: Deploy via VS Code

1. Instalar extensão "Azure Functions" no VS Code
2. Abrir pasta `azure-functions`
3. Click direito > Deploy to Function App
4. Selecionar: `func-jsmc-contact-prod`

## 🔧 Configuração

### 1. SendGrid API Key

Criar conta SendGrid (100 emails/dia grátis):

1. Acesse https://sendgrid.com/
2. Crie API Key com permissão "Mail Send"
3. Armazene no Key Vault:

```bash
az keyvault secret set \
  --vault-name kv-jsmc-web-prod \
  --name sendgrid-api-key \
  --value "SG.xxxxxxxxxxxxx"
```

### 2. Application Settings

Configurar variáveis de ambiente:

```bash
az functionapp config appsettings set \
  --name func-jsmc-contact-prod \
  --resource-group rg-jsmc-website-prod \
  --settings \
    "FROM_EMAIL=informacoes@jsmc.com.br" \
    "TO_EMAIL=informacoes@jsmc.com.br" \
    "BCC_EMAIL=" \
    "CORS_ORIGINS=https://jsmc.com.br,https://www.jsmc.com.br" \
    "SENDGRID_API_KEY=@Microsoft.KeyVault(SecretUri=https://kv-jsmc-web-prod.vault.azure.net/secrets/sendgrid-api-key/)"
```

## 🧪 Teste Local

```bash
# Instalar Azure Functions Core Tools
npm install -g azure-functions-core-tools@4

# Configurar local.settings.json
cat > local.settings.json << EOF
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FROM_EMAIL": "informacoes@jsmc.com.br",
    "TO_EMAIL": "informacoes@jsmc.com.br",
    "SENDGRID_API_KEY": "SG.xxxxxxx",
    "CORS_ORIGINS": "http://localhost:8080"
  }
}
EOF

# Iniciar função localmente
npm start

# Testar endpoint (em outro terminal)
curl -X POST http://localhost:7071/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Teste Local",
    "email": "teste@example.com",
    "subject": "consultoria",
    "message": "Esta é uma mensagem de teste local."
  }'
```

## 📊 Monitoramento

### Application Insights

Ver logs e métricas:

```bash
# Logs recentes
az monitor app-insights query \
  --app appi-jsmc-website-prod \
  --resource-group rg-jsmc-website-prod \
  --analytics-query "traces | where timestamp > ago(1h) | order by timestamp desc"

# Ver erros
az monitor app-insights query \
  --app appi-jsmc-website-prod \
  --resource-group rg-jsmc-website-prod \
  --analytics-query "exceptions | where timestamp > ago(1d) | project timestamp, type, outerMessage"
```

## 🔐 Segurança

- ✅ CORS configurado para domínios específicos
- ✅ HTTPS only (enforced)
- ✅ API Key no Key Vault (não em código)
- ✅ Validação rigorosa de dados
- ✅ Escape HTML anti-XSS
- ✅ Auth level: anonymous (formulário público)

## 📝 Diferenças vs AWS Lambda

| Feature | AWS Lambda | Azure Functions |
|---------|------------|-----------------|
| Email | AWS SES | SendGrid |
| Trigger | API Gateway | HTTP Trigger |
| Secrets | Secrets Manager | Key Vault |
| Logs | CloudWatch | App Insights |
| Cost | $0.20/1M req | $0.20/1M exec |

## 🆘 Troubleshooting

**Erro: "SENDGRID_API_KEY não configurada"**

```bash
# Verificar configuração
az functionapp config appsettings list \
  --name func-jsmc-contact-prod \
  --resource-group rg-jsmc-website-prod | grep SENDGRID
```

**Email não chega**

1. Verificar logs no Application Insights
2. Verificar SendGrid Dashboard > Activity
3. Verificar pasta spam
4. Verificar FROM_EMAIL está verificado no SendGrid

---

**Versão**: 1.0.0  
**Status**: Production Ready ✅
