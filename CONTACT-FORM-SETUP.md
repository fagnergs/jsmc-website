# 📧 Setup do Formulário de Contato - JSMC Soluções

Este guia explica como configurar o formulário de contato funcional usando AWS Lambda, API Gateway e SES (Simple Email Service).

## 📋 Arquitetura

```
Frontend (Website)
    ↓
API Gateway (HTTPS endpoint)
    ↓
Lambda Function (Node.js)
    ↓
AWS SES (Envio de email)
    ↓
informacoes@jsmc.com.br
```

---

## 🚀 Passo a Passo - Setup Completo

### **Passo 1: Verificar Emails no AWS SES**

⏱️ Tempo estimado: 10 minutos

O AWS SES requer que você verifique os emails que serão usados para enviar e receber mensagens.

```bash
# 1. Acessar AWS Console
https://console.aws.amazon.com/ses/

# 2. Navegar para: Email Addresses > Verify a New Email Address

# 3. Adicionar emails:
   - informacoes@jsmc.com.br (remetente e destinatário)
   - Outros emails que queira receber cópia (opcional)

# 4. Verificar email
   - Abrir email recebido da AWS
   - Clicar no link de verificação
   - Status deve mudar para "verified" (verde)
```

**IMPORTANTE:** Por padrão, AWS SES está em "Sandbox mode", que só permite enviar emails para endereços verificados. Para produção:

```bash
# Solicitar saída do Sandbox (produção)
# https://console.aws.amazon.com/ses/ > Account Dashboard > Request Production Access

# Preencher formulário:
# - Use case: Transactional emails (contact form)
# - Website: https://jsmc.com.br
# - Describe how you will comply with AWS policies
# - Estimativa: < 1000 emails/mês
```

---

### **Passo 2: Deploy da Infraestrutura AWS**

⏱️ Tempo estimado: 15 minutos

Deploy do CloudFormation stack que cria Lambda, API Gateway, IAM Roles, etc.

```bash
# 1. Navegar para o diretório do projeto
cd /caminho/para/jsmc-website

# 2. Deploy via AWS CLI
aws cloudformation create-stack \
  --stack-name jsmc-contact-form-stack \
  --template-body file://aws-contact-form-infrastructure.yaml \
  --parameters \
      ParameterKey=FromEmail,ParameterValue=informacoes@jsmc.com.br \
      ParameterKey=ToEmail,ParameterValue=informacoes@jsmc.com.br \
      ParameterKey=Environment,ParameterValue=production \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-east-1

# 3. Aguardar conclusão (5-10 minutos)
aws cloudformation wait stack-create-complete \
  --stack-name jsmc-contact-form-stack \
  --region us-east-1

# 4. Obter outputs do stack
aws cloudformation describe-stacks \
  --stack-name jsmc-contact-form-stack \
  --region us-east-1 \
  --query 'Stacks[0].Outputs' \
  --output table
```

**Outputs importantes:**
- `APIEndpoint`: URL do API Gateway (exemplo: https://abc123.execute-api.us-east-1.amazonaws.com/production/contact)
- `LambdaFunctionName`: Nome da função Lambda

**Copie o valor de APIEndpoint**, você vai precisar no Passo 4!

---

### **Passo 3: Deploy do Código Lambda**

⏱️ Tempo estimado: 5 minutos

O código da Lambda precisa ser deployado manualmente (ou via GitHub Actions).

```bash
# 1. Entrar no diretório Lambda
cd lambda

# 2. Instalar dependências
npm install

# 3. Criar arquivo ZIP
zip -r function.zip . -x "*.git*" -x "*node_modules/.cache*"

# 4. Upload para Lambda
aws lambda update-function-code \
  --function-name jsmc-contact-form-handler-production \
  --zip-file fileb://function.zip \
  --region us-east-1

# 5. Verificar sucesso
aws lambda get-function \
  --function-name jsmc-contact-form-handler-production \
  --region us-east-1 \
  --query 'Configuration.[FunctionName,LastModified,State]' \
  --output table
```

---

### **Passo 4: Configurar API Endpoint no Frontend**

⏱️ Tempo estimado: 2 minutos

Agora você precisa configurar o frontend para usar o API Gateway endpoint.

**Opção A: Editar js/config.js (RECOMENDADO)**

```javascript
// Arquivo: js/config.js

window.JSMC_CONFIG = {
    // Substituir pela URL real do Passo 2
    API_ENDPOINT: 'https://abc123xyz.execute-api.us-east-1.amazonaws.com/production/contact',

    ENVIRONMENT: 'production',
    VERSION: '11.0.0'
};
```

**Opção B: Adicionar inline no HTML**

```html
<!-- Antes do </head> no index.html -->
<script>
  window.JSMC_CONFIG = {
    API_ENDPOINT: 'https://abc123xyz.execute-api.us-east-1.amazonaws.com/production/contact'
  };
</script>
```

---

### **Passo 5: Deploy do Website**

⏱️ Tempo estimado: 1 minuto

```bash
# Fazer commit das mudanças
git add .
git commit -m "feat: v11 - adicionar formulário de contato funcional com AWS Lambda + SES"

# Push para deploy automático (GitHub Actions)
git push origin develop
```

O GitHub Actions vai fazer deploy automático para S3 + invalidar CloudFront.

---

### **Passo 6: Testar o Formulário**

⏱️ Tempo estimado: 3 minutos

1. **Acessar o website:** https://jsmc.com.br
2. **Ir para seção de Contato**
3. **Preencher formulário:**
   - Nome: Seu Nome
   - Email: seu-email@example.com
   - Empresa: Sua Empresa
   - Assunto: Consultoria em Energia
   - Mensagem: Teste de integração do formulário

4. **Clicar em "Enviar Mensagem"**
5. **Verificar:**
   - ✅ Botão muda para "✓ Mensagem enviada com sucesso!"
   - ✅ Formulário é limpo
   - ✅ Email chega em informacoes@jsmc.com.br

---

## 🔧 Troubleshooting

### Problema: "API_ENDPOINT não configurado"

**Causa:** Frontend está usando modo demo (sem API configurada)

**Solução:**
1. Verificar se `js/config.js` tem API_ENDPOINT definido
2. Verificar se CloudFormation stack foi criado com sucesso
3. Obter API_ENDPOINT dos outputs do CloudFormation

```bash
aws cloudformation describe-stacks \
  --stack-name jsmc-contact-form-stack \
  --query 'Stacks[0].Outputs[?OutputKey==`APIEndpoint`].OutputValue' \
  --output text
```

---

### Problema: "Erro 403 - Access Denied"

**Causa:** CORS não configurado ou Lambda sem permissões

**Solução:**
1. Verificar headers CORS no API Gateway
2. Verificar IAM Role da Lambda tem permissão para SES
3. Testar Lambda diretamente:

```bash
aws lambda invoke \
  --function-name jsmc-contact-form-handler-production \
  --payload '{"httpMethod":"POST","body":"{\"name\":\"Teste\",\"email\":\"teste@example.com\",\"subject\":\"consultoria\",\"message\":\"Teste\"}"}' \
  response.json

cat response.json
```

---

### Problema: "Email não chega"

**Causa:** Email não verificado no SES ou SES em Sandbox mode

**Solução 1 - Verificar email:**
```bash
# Listar emails verificados
aws ses list-verified-email-addresses --region us-east-1
```

**Solução 2 - Sair do Sandbox:**
1. Acessar: https://console.aws.amazon.com/ses/
2. Account Dashboard > Request Production Access
3. Preencher formulário (aprovação em 24-48h)

**Solução 3 - Verificar logs da Lambda:**
```bash
# Ver logs recentes
aws logs tail /aws/lambda/jsmc-contact-form-handler-production --follow
```

---

### Problema: "CORS Error" no navegador

**Causa:** API Gateway não está retornando headers CORS corretos

**Solução:**
1. Verificar se método OPTIONS está configurado no API Gateway
2. Verificar se Lambda retorna headers corretos
3. Redeployar API Gateway:

```bash
aws apigateway create-deployment \
  --rest-api-id <API_ID> \
  --stage-name production \
  --region us-east-1
```

---

## 📊 Monitoramento

### CloudWatch Logs

Ver logs da Lambda em tempo real:

```bash
# Logs em tempo real
aws logs tail /aws/lambda/jsmc-contact-form-handler-production --follow

# Últimos 10 minutos
aws logs tail /aws/lambda/jsmc-contact-form-handler-production --since 10m

# Buscar erros
aws logs filter-log-events \
  --log-group-name /aws/lambda/jsmc-contact-form-handler-production \
  --filter-pattern "ERROR" \
  --start-time $(date -u -d '1 hour ago' +%s)000
```

### Métricas CloudWatch

```bash
# Invocações da Lambda (últimas 24h)
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=jsmc-contact-form-handler-production \
  --start-time $(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 3600 \
  --statistics Sum \
  --region us-east-1

# Erros da Lambda
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Errors \
  --dimensions Name=FunctionName,Value=jsmc-contact-form-handler-production \
  --start-time $(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 3600 \
  --statistics Sum \
  --region us-east-1
```

### Painel CloudWatch

Criar dashboard personalizado:
1. Acessar: https://console.aws.amazon.com/cloudwatch/
2. Dashboards > Create Dashboard
3. Adicionar widgets:
   - Lambda Invocations
   - Lambda Errors
   - Lambda Duration
   - API Gateway 4XX/5XX Errors

---

## 💰 Custos Estimados

### AWS SES
- **Primeiros 62.000 emails/mês:** GRÁTIS (se enviados de EC2, Lambda, etc.)
- **Após 62.000 emails:** $0.10 por 1.000 emails

### AWS Lambda
- **Primeiras 1 milhão invocações/mês:** GRÁTIS
- **Após 1 milhão:** $0.20 por 1 milhão
- **Memória (256MB, 1s/invocação):** ~$0.0000004 por invocação

### API Gateway
- **Primeiras 1 milhão requisições/mês:** ~$3.50
- **Após 1 milhão:** $1.00 por 1 milhão

### **Estimativa para website JSMC (~100 contatos/mês):**
- **Total:** ~$1-2/mês (praticamente FREE tier)

---

## 🔐 Segurança

### Implementado
- ✅ HTTPS obrigatório (API Gateway)
- ✅ CORS configurado
- ✅ Validação de inputs (Lambda)
- ✅ Escape de HTML (prevenção XSS)
- ✅ IAM Roles com privilégio mínimo
- ✅ CloudWatch logging
- ✅ Rate limiting (API Gateway - 10req/s por padrão)

### Melhorias Futuras (Opcional)
- [ ] Adicionar reCAPTCHA v3
- [ ] Rate limiting por IP
- [ ] WAF (Web Application Firewall)
- [ ] Encryption at rest para logs
- [ ] Honeypot fields no formulário

---

## 📝 Manutenção

### Atualizar código da Lambda

```bash
cd lambda
npm install  # se houver novas dependências
zip -r function.zip .
aws lambda update-function-code \
  --function-name jsmc-contact-form-handler-production \
  --zip-file fileb://function.zip
```

### Atualizar infraestrutura (CloudFormation)

```bash
aws cloudformation update-stack \
  --stack-name jsmc-contact-form-stack \
  --template-body file://aws-contact-form-infrastructure.yaml \
  --parameters \
      ParameterKey=FromEmail,ParameterValue=informacoes@jsmc.com.br \
      ParameterKey=ToEmail,ParameterValue=informacoes@jsmc.com.br \
  --capabilities CAPABILITY_NAMED_IAM
```

### Deletar stack (se necessário)

```bash
aws cloudformation delete-stack \
  --stack-name jsmc-contact-form-stack \
  --region us-east-1
```

---

## 🎯 Checklist Final

Antes de considerar completo, verifique:

```
[ ] Emails verificados no AWS SES
[ ] CloudFormation stack criado com sucesso
[ ] Lambda code deployado
[ ] API_ENDPOINT configurado no frontend
[ ] Website deployado com mudanças
[ ] Formulário testado e funcionando
[ ] Email recebido em informacoes@jsmc.com.br
[ ] Logs no CloudWatch funcionando
[ ] Alarmes configurados (opcional)
[ ] SES fora do Sandbox (produção)
```

---

## 📞 Suporte

Para dúvidas ou problemas:
- 📧 Email: informacoes@jsmc.com.br
- 📱 Telefone: +55 (11) 92002-9999
- 📖 Documentação AWS SES: https://docs.aws.amazon.com/ses/
- 📖 Documentação AWS Lambda: https://docs.aws.amazon.com/lambda/

---

**Desenvolvido com ❤️ para JSMC Soluções**
Versão: 11.0.0
Data: Dezembro 2024
