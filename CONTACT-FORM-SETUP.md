# 📧 Setup do Formulário de Contato - JSMC Soluções

Este guia explica como configurar o formulário de contato funcional usando AWS Lambda, API Gateway e SES (Simple Email Service).

## ⚠️ IMPORTANTE - Contexto do Ambiente

**Situação atual:**
- ✅ Domínio **jsmc.com.br** hospedado no **Office 365 (Microsoft)**
- ✅ Email corporativo funcionando normalmente via Office 365
- ✅ Lista de distribuição **informacoes@jsmc.com.br** → encaminha para:
  - fagner.silva@jsmc.com.br
  - joao.souza@jsmc.com.br
- 🎯 Objetivo: Usar AWS SES APENAS para enviar emails do formulário do website
- 🛡️ Garantia: NÃO quebrar emails corporativos existentes

**Estratégia:**
- AWS SES será usado APENAS para **envio** (não recebimento)
- Office 365 continua sendo o servidor de email principal (MX records)
- Não há necessidade de alterar MX records no DNS
- Apenas adicionar registros SPF/DKIM para autenticação AWS SES

## 📋 Arquitetura

```
Frontend (jsmc.com.br)
    ↓
API Gateway (HTTPS)
    ↓
Lambda Function
    ↓
AWS SES (ENVIO apenas)
    ↓
📧 informacoes@jsmc.com.br
    ↓
Office 365 (lista distribuição)
    ↓
✅ fagner.silva@jsmc.com.br
✅ joao.souza@jsmc.com.br
```

---

## 🚀 Passo a Passo - Setup Completo

### **Passo 1: Configurar AWS SES (Apenas Envio)**

⏱️ Tempo estimado: 20-30 minutos

#### 📌 **Parte A: Entender as Opções**

Você tem **2 opções** para configurar AWS SES:

**Opção 1: Verificar Emails Individuais (MAIS SIMPLES)** ⭐ RECOMENDADO
- ✅ Rápido (5 minutos)
- ✅ Sem alterações no DNS
- ✅ Não afeta Office 365
- ⚠️ Limitação: Só envia de emails verificados individualmente

**Opção 2: Verificar Domínio Completo (MAIS AVANÇADO)**
- ✅ Permite enviar de qualquer email @jsmc.com.br
- ✅ Melhor reputação de envio (SPF/DKIM)
- ⚠️ Requer alterações no DNS (não afeta MX records)
- ⏱️ Mais demorado (20-30 min)

---

#### 📧 **OPÇÃO 1: Verificar Email Individual (Recomendado para Começar)**

Esta opção é ideal para começar rapidamente e testar. **Não requer alterações no DNS.**

##### **1.1. Acessar AWS SES Console**

```
https://console.aws.amazon.com/ses/
```

**⚠️ IMPORTANTE:** Certifique-se de estar na região **us-east-1 (N. Virginia)**

##### **1.2. Verificar Email de Envio (FROM)**

```bash
# Na AWS Console SES:
1. Menu lateral: "Verified identities" > "Create identity"
2. Selecionar: "Email address"
3. Email: noreply@jsmc.com.br
   (ou outro email que você controla no Office 365)
4. Clicar: "Create identity"

# Você receberá um email da AWS no Office 365
5. Abrir inbox do Office 365: noreply@jsmc.com.br
6. Procurar email: "Amazon Web Services – Email Address Verification Request"
7. Clicar no link de verificação
8. Status mudará para "Verified" ✅
```

**💡 Por que usar noreply@jsmc.com.br?**
- É um email que você controla no Office 365
- Indica claramente que é enviado automaticamente
- Seguindo boas práticas de email transacional

##### **1.3. Verificar Emails de Destino (TO)**

Como o SES está em **Sandbox mode** por padrão, você precisa verificar os emails que vão **receber** mensagens:

```bash
# Repetir processo acima para:
1. informacoes@jsmc.com.br
2. fagner.silva@jsmc.com.br
3. joao.souza@jsmc.com.br

# Para cada email:
- Menu: "Verified identities" > "Create identity"
- Selecionar: "Email address"
- Inserir email
- Verificar na caixa de entrada (Office 365)
```

##### **1.4. Solicitar Saída do Sandbox (Produção)**

⏱️ **Aprovação: 24-48 horas**

```bash
# No AWS SES Console:
1. Menu: "Account dashboard"
2. Clicar: "Request production access"
3. Preencher formulário:

   Mail Type: Transactional
   Website URL: https://jsmc.com.br
   Use Case Description:
   "Website contact form for JSMC Soluções, energy consulting company.
    Sending transactional emails only when users submit contact form.
    Expected volume: < 100 emails/month.
    Emails will be sent to verified business email addresses only."

   Compliance:
   "We only send emails when users explicitly submit our contact form.
    We do not send marketing emails. All recipients are verified business contacts."

4. Submit
```

**Enquanto aguarda aprovação:**
- ✅ Você pode continuar no Sandbox mode
- ✅ Só consegue enviar para emails verificados
- ✅ Suficiente para desenvolvimento e testes

**Após aprovação:**
- ✅ Pode enviar para qualquer email
- ✅ Limite de 50.000 emails/dia
- ✅ Pronto para produção

---

#### 🌐 **OPÇÃO 2: Verificar Domínio Completo (Avançado)**

Esta opção permite enviar de qualquer email @jsmc.com.br e melhora a reputação de entrega.

**⚠️ ATENÇÃO:** Requer alterações no DNS, mas **NÃO afeta o Office 365**

##### **2.1. Verificar Domínio no SES**

```bash
# No AWS SES Console:
1. Menu: "Verified identities" > "Create identity"
2. Selecionar: "Domain"
3. Domain: jsmc.com.br
4. Advanced DKIM settings: "Easy DKIM" (deixar padrão)
5. Clicar: "Create identity"
```

##### **2.2. Obter Registros DNS**

A AWS vai gerar 3 tipos de registros DNS:

```
📋 REGISTROS FORNECIDOS PELA AWS:

1. DKIM Records (3 registros CNAME):
   - xxxxx._domainkey.jsmc.com.br → xxxxx.dkim.amazonses.com
   - yyyyy._domainkey.jsmc.com.br → yyyyy.dkim.amazonses.com
   - zzzzz._domainkey.jsmc.com.br → zzzzz.dkim.amazonses.com

2. Domínio Verification (1 registro TXT):
   - _amazonses.jsmc.com.br → "valor-gerado-pela-aws"

3. SPF (opcional, recomendado)
```

##### **2.3. Adicionar Registros no DNS Microsoft (Office 365)**

**🔐 IMPORTANTE: Estas alterações NÃO afetam o Office 365!**
- ✅ MX records continuam apontando para Office 365
- ✅ Email corporativo continua funcionando normalmente
- ✅ Apenas adiciona autenticação extra para AWS SES

##### **🖥️ Passo-a-Passo no Portal Microsoft 365:**

```bash
1. Acessar Admin Center:
   https://admin.microsoft.com

2. Navegar para DNS:
   Settings > Domains > jsmc.com.br > DNS records

3. Clicar: "Add record" ou "Custom records"
```

##### **📝 Adicionar DKIM Records (3 registros):**

Para cada um dos 3 registros DKIM fornecidos pela AWS:

```
Tipo: CNAME
Nome/Host: xxxxx._domainkey
Aponta para: xxxxx.dkim.amazonses.com
TTL: 3600 (ou deixar padrão)

Tipo: CNAME
Nome/Host: yyyyy._domainkey
Aponta para: yyyyy.dkim.amazonses.com
TTL: 3600

Tipo: CNAME
Nome/Host: zzzzz._domainkey
Aponta para: zzzzz.dkim.amazonses.com
TTL: 3600
```

⚠️ **NOTA:** Os valores `xxxxx`, `yyyyy`, `zzzzz` serão strings longas fornecidas pela AWS.

##### **📝 Adicionar Verification Record (1 registro):**

```
Tipo: TXT
Nome/Host: _amazonses
Valor: "valor-longo-fornecido-pela-aws"
TTL: 3600
```

##### **📝 Atualizar SPF Record (se necessário):**

**Verificar registro SPF existente:**

```bash
# Via terminal ou ferramenta online
nslookup -type=TXT jsmc.com.br

# Você verá algo como:
"v=spf1 include:spf.protection.outlook.com ~all"
```

**Se o SPF já existe (provavelmente sim para Office 365):**

```
Tipo: TXT
Nome/Host: @ (ou jsmc.com.br ou deixe vazio)
Valor ANTIGO: "v=spf1 include:spf.protection.outlook.com ~all"
Valor NOVO:   "v=spf1 include:spf.protection.outlook.com include:amazonses.com ~all"
                          ↑ Office 365 mantido     ↑ AWS SES adicionado
```

⚠️ **CUIDADO:**
- Apenas ADICIONE `include:amazonses.com` ao registro existente
- NÃO substitua o registro inteiro
- NÃO remova `include:spf.protection.outlook.com`

**Se o SPF NÃO existe (improvável):**

```
Tipo: TXT
Nome/Host: @ (ou jsmc.com.br)
Valor: "v=spf1 include:spf.protection.outlook.com include:amazonses.com ~all"
```

##### **2.4. Aguardar Propagação DNS**

```bash
# Tempo de propagação: 15 minutos a 72 horas (geralmente < 1 hora)

# Verificar status no AWS SES:
1. Menu: "Verified identities"
2. Clicar em: jsmc.com.br
3. Status deve mudar para "Verified" ✅

# Verificar DNS propagou (via terminal):
nslookup -type=CNAME xxxxx._domainkey.jsmc.com.br
nslookup -type=TXT _amazonses.jsmc.com.br
nslookup -type=TXT jsmc.com.br  # Ver SPF
```

##### **2.5. Testar Configuração**

```bash
# No AWS SES Console:
1. Menu: "Verified identities" > jsmc.com.br
2. Aba: "Authentication"
3. Verificar:
   - DKIM status: ✅ Successful
   - Domain status: ✅ Verified
```

---

#### ✅ **Checklist Passo 1 Concluído**

**Opção 1 (Email Individual):**
```
[ ] noreply@jsmc.com.br verificado no SES
[ ] informacoes@jsmc.com.br verificado no SES
[ ] fagner.silva@jsmc.com.br verificado no SES (opcional)
[ ] joao.souza@jsmc.com.br verificado no SES (opcional)
[ ] Request production access submetido (aguardar aprovação)
```

**Opção 2 (Domínio Completo):**
```
[ ] Domínio jsmc.com.br verificado no SES
[ ] 3 registros DKIM adicionados no DNS Microsoft
[ ] 1 registro _amazonses TXT adicionado
[ ] SPF atualizado (include:amazonses.com adicionado)
[ ] DNS propagado (verificado via nslookup)
[ ] Status "Verified" no AWS SES Console
[ ] Request production access submetido
```

---

#### 🔍 **Troubleshooting Passo 1**

**Problema: Email de verificação não chega**
```
Solução:
1. Verificar pasta de SPAM/Lixo Eletrônico no Office 365
2. Aguardar até 15 minutos
3. Reenviar verificação no AWS Console
```

**Problema: DNS não propaga (Opção 2)**
```
Solução:
1. Verificar registros no Admin Microsoft 365
2. Aguardar até 1 hora
3. Testar com: https://mxtoolbox.com/SuperTool.aspx?action=txt:_amazonses.jsmc.com.br
4. Verificar TTL está correto (3600)
```

**Problema: SPF com múltiplos includes excede limite**
```
SPF tem limite de 10 "includes"
Solução: Consolidar ou usar ferramentas de flattening
Ferramenta: https://www.autospf.com/
```

**Preocupação: "Vou quebrar o Office 365?"**
```
✅ NÃO VAI QUEBRAR!
- MX records continuam intocados (apontam para Microsoft)
- Você está apenas ADICIONANDO registros extras
- Office 365 continuará recebendo emails normalmente
- AWS SES só será usado para ENVIAR via Lambda
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
