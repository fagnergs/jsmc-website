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

### **Passo 2: Criar Infraestrutura AWS (Manual via Console)**

⏱️ Tempo estimado: 30-40 minutos

Vamos criar todos os componentes manualmente via AWS Console. Isto dá maior controle e entendimento de cada peça.

**Ordem de criação:**
1. IAM Role para Lambda
2. Lambda Function
3. API Gateway
4. Testar integração

---

#### **2.1. Criar IAM Role para Lambda**

A Lambda precisa de permissões para enviar emails via SES e escrever logs.

##### **Passo-a-Passo:**

```bash
1. Acessar IAM Console:
   https://console.aws.amazon.com/iam/

2. Menu lateral: "Roles" > "Create role"

3. Trusted entity type: "AWS service"
   Use case: "Lambda"
   Clicar: "Next"

4. Add permissions - Selecionar políticas:
   ☑️ AWSLambdaBasicExecutionRole
   (Permite escrever logs no CloudWatch)

5. Clicar: "Next"

6. Role details:
   Role name: jsmc-contact-form-lambda-role
   Description: "Permite Lambda enviar emails via SES e escrever logs"

7. Clicar: "Create role"
```

##### **Adicionar Permissão SES:**

A política `AWSLambdaBasicExecutionRole` só dá acesso a logs. Precisamos adicionar SES.

```bash
1. Na lista de Roles, clicar em: jsmc-contact-form-lambda-role

2. Aba "Permissions" > "Add permissions" > "Create inline policy"

3. Clicar aba "JSON" e colar:
```

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ses:FromAddress": "noreply@jsmc.com.br"
        }
      }
    }
  ]
}
```

```bash
4. Clicar: "Next"

5. Policy name: SESEmailSendingPolicy

6. Clicar: "Create policy"
```

✅ **Resultado:** Role criada com ARN parecido com:
```
arn:aws:iam::123456789012:role/jsmc-contact-form-lambda-role
```

---

#### **2.2. Criar Lambda Function**

Agora vamos criar a função Lambda que processa o formulário.

##### **Passo-a-Passo:**

```bash
1. Acessar Lambda Console:
   https://console.aws.amazon.com/lambda/

2. Clicar: "Create function"

3. Selecionar: "Author from scratch"

4. Function name: jsmc-contact-form-handler

5. Runtime: Node.js 18.x

6. Architecture: x86_64

7. Permissions:
   ☑️ "Use an existing role"
   Existing role: jsmc-contact-form-lambda-role

8. Clicar: "Create function"
```

##### **Configurar Variáveis de Ambiente:**

```bash
1. Na página da função, aba "Configuration"

2. Menu lateral: "Environment variables" > "Edit"

3. Adicionar variáveis:

   Key: FROM_EMAIL
   Value: noreply@jsmc.com.br

   Key: TO_EMAIL
   Value: informacoes@jsmc.com.br

   Key: ENVIRONMENT
   Value: production

4. Clicar: "Save"
```

**⚠️ IMPORTANTE:**
- NÃO adicione `AWS_REGION` - é uma variável **reservada** pela AWS Lambda
- A região já está automaticamente configurada como `us-east-1`
- Se tentar adicionar, receberá erro: "reserved keys that are currently not supported for modification"

##### **Ajustar Configurações:**

```bash
1. Aba "Configuration" > "General configuration" > "Edit"

2. Timeout: 30 segundos
   (padrão é 3s, pode ser pouco para SES)

3. Memory: 256 MB
   (suficiente para envio de emails)

4. Clicar: "Save"
```

##### **Upload do Código via GitHub Actions:**

Vamos configurar deploy automático pelo GitHub em vez de upload manual de ZIP.

**Vantagens:**
- ✅ Deploy automático em cada push
- ✅ Código versionado no Git
- ✅ Histórico completo de mudanças
- ✅ Teste automático após deploy

**Passo 1: Criar IAM Role para GitHub Actions**

```bash
1. No Console AWS: IAM > Roles > "Create role"

2. Trusted entity type: "Web identity"

3. Identity provider:
   - Provider: "token.actions.githubusercontent.com"
   - Audience: "sts.amazonaws.com"

4. Clicar: "Next"

5. Attach permission policies (criar inline policy):
   - Clicar: "Create policy" > JSON
   - Colar JSON abaixo
   - Nome: "GitHubActionsLambdaDeploy"

6. Clicar: "Next"

7. Role name: "github-actions-lambda-deploy"

8. Clicar: "Create role"

9. COPIAR o ARN (vamos precisar):
   Exemplo: arn:aws:iam::781705467769:role/github-actions-lambda-deploy
```

**JSON da Policy:**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:UpdateFunctionCode",
        "lambda:GetFunction",
        "lambda:GetFunctionConfiguration"
      ],
      "Resource": "arn:aws:lambda:us-east-1:781705467769:function:jsmc-contact-form-handler"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:DescribeLogStreams",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ],
      "Resource": "arn:aws:logs:us-east-1:781705467769:log-group:/aws/lambda/jsmc-contact-form-handler:*"
    }
  ]
}
```

**Passo 2: Configurar GitHub Secrets**

```bash
1. No GitHub: Settings > Secrets and variables > Actions

2. Clicar: "New repository secret"

3. Name: AWS_LAMBDA_DEPLOY_ROLE_ARN
   Value: arn:aws:iam::781705467769:role/github-actions-lambda-deploy
   (use o ARN que você copiou acima)

4. Clicar: "Add secret"
```

**Passo 3: Fazer Deploy via Git**

```bash
1. No terminal, no diretório do projeto:
   cd /Users/fagnergs/Documents/GitHub/jsmc-website

2. Verificar status:
   git status

3. Adicionar arquivos Lambda:
   git add lambda/
   git add .github/workflows/deploy-lambda.yml

4. Fazer commit:
   git commit -m "feat: adicionar código Lambda para formulário de contato"

5. Push para trigger o deploy:
   git push origin develop

6. Acompanhar deploy:
   - GitHub > Actions tab
   - Ver workflow "Deploy Lambda Function" rodando
   - Deploy leva ~2-3 minutos

7. Verificar sucesso:
   ✅ Green checkmark no workflow
   ✅ Mensagem: "Lambda funcionando corretamente!"
```

**Passo 4: Verificar Lambda foi Atualizada**

```bash
1. Console AWS > Lambda > jsmc-contact-form-handler

2. Aba "Code" > Code source
   - Deve mostrar contact-form-handler.js
   - Última modificação deve ser recente

3. Aba "Monitor" > "View CloudWatch logs"
   - Ver logs do teste automático do GitHub Actions
```

**Troubleshooting:**

❌ **Erro: "User is not authorized to perform: sts:AssumeRoleWithWebIdentity"**
- Solução: Editar Trust Relationship da Role do GitHub Actions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::781705467769:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:fagnergs/jsmc-website:*"
        }
      }
    }
  ]
}
```

❌ **Erro: "AccessDeniedException: User is not authorized to perform: lambda:UpdateFunctionCode"**
- Solução: Verificar ARN da função na policy IAM está correto
- Verificar secret AWS_LAMBDA_DEPLOY_ROLE_ARN está correto no GitHub

**Deployments Futuros:**

Agora qualquer mudança na pasta `lambda/` dispara deploy automático:

```bash
# Editar código
vim lambda/contact-form-handler.js

# Commit e push
git add lambda/
git commit -m "fix: corrigir validação de email"
git push origin develop

# Deploy acontece automaticamente! 🚀
```

##### **Testar Lambda (Opcional):**

```bash
1. Aba "Test" > "Create new test event"

2. Event name: ContactFormTest

3. Event JSON:
```

```json
{
  "httpMethod": "POST",
  "body": "{\"name\":\"Teste Lambda\",\"email\":\"fagner.silva@jsmc.com.br\",\"subject\":\"consultoria\",\"message\":\"Teste de integração\"}"
}
```

```bash
4. Clicar: "Save"

5. Clicar: "Test"

6. Verificar resposta:
   ✅ Status code: 200
   ✅ Body: {"success":true,"message":"Mensagem enviada com sucesso!"}

7. Verificar email chegou em informacoes@jsmc.com.br
```

✅ **Resultado:** Lambda criada e testada!

---

#### **2.3. Criar API Gateway**

Agora vamos expor a Lambda via API REST pública.

##### **Criar REST API:**

```bash
1. Acessar API Gateway Console:
   https://console.aws.amazon.com/apigateway/

2. Clicar: "Create API"

3. Selecionar: "REST API" (não private)
   Clicar: "Build"

4. Choose the protocol: REST
   Create new API: New API

5. API name: jsmc-contact-form-api

6. Description: API Gateway para formulário de contato

7. Endpoint Type: Regional

8. Clicar: "Create API"
```

##### **Criar Resource (Endpoint /contact):**

```bash
1. Na API criada, clicar: "Actions" > "Create Resource"

2. Resource Name: contact

3. Resource Path: /contact
   (será auto-preenchido)

4. ☑️ Enable API Gateway CORS
   (IMPORTANTE para aceitar requisições do website)

5. Clicar: "Create Resource"
```

##### **Criar Método POST:**

```bash
1. Com resource /contact selecionado:
   Clicar: "Actions" > "Create Method"

2. Dropdown: Selecionar "POST" > ✓ (check)

3. Setup:
   Integration type: Lambda Function

   ☑️ Use Lambda Proxy integration
   (IMPORTANTE para passar request completo)

   Lambda Region: us-east-1

   Lambda Function: jsmc-contact-form-handler
   (começar a digitar e auto-completar)

4. Clicar: "Save"

5. Popup "Add Permission to Lambda Function":
   Clicar: "OK"
   (Isso permite API Gateway invocar a Lambda)
```

##### **Configurar CORS (se não ativou antes):**

Se não marcou "Enable CORS" na criação do resource:

```bash
1. Selecionar resource: /contact

2. Clicar: "Actions" > "Enable CORS"

3. Deixar padrões:
   Access-Control-Allow-Methods: POST,OPTIONS
   Access-Control-Allow-Headers: (deixar padrão)
   Access-Control-Allow-Origin: '*'

4. Clicar: "Enable CORS and replace existing CORS headers"

5. Confirmar: "Yes, replace existing values"
```

##### **Deploy da API:**

```bash
1. Clicar: "Actions" > "Deploy API"

2. Deployment stage: [New Stage]

3. Stage name: production

4. Stage description: Ambiente de produção

5. Deployment description: Deploy inicial

6. Clicar: "Deploy"
```

##### **Obter URL da API:**

```bash
1. Na tela "Stages" > production

2. No topo, copiar: "Invoke URL"

   Exemplo:
   https://abc12345.execute-api.us-east-1.amazonaws.com/production

3. Adicionar /contact ao final:
   https://abc12345.execute-api.us-east-1.amazonaws.com/production/contact

4. ⭐ COPIAR ESTA URL COMPLETA ⭐
   (você vai usar no Passo 3)
```

✅ **Resultado:** API Gateway criada e configurada!

---

#### **2.4. Testar API Gateway (via cURL)**

Antes de integrar ao website, teste se a API está funcionando:

```bash
# No terminal (Mac/Linux) ou Git Bash (Windows):

curl -X POST https://SUA-URL-AQUI.execute-api.us-east-1.amazonaws.com/production/contact \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Teste API",
    "email": "fagner.silva@jsmc.com.br",
    "subject": "consultoria",
    "message": "Teste de integração via cURL"
  }'

# Resposta esperada:
{"success":true,"message":"Mensagem enviada com sucesso!"}
```

**Se der erro 403 Forbidden:**
- Verificar CORS está habilitado
- Verificar método POST foi criado
- Verificar deploy foi feito

**Se der erro 500 Internal:**
- Ver logs da Lambda: CloudWatch > Log groups > /aws/lambda/jsmc-contact-form-handler
- Verificar variáveis de ambiente estão corretas
- Verificar emails estão verificados no SES

✅ **Teste bem-sucedido:** Email deve chegar em informacoes@jsmc.com.br!

---

#### ✅ **Checklist Passo 2 Concluído**

```
[ ] IAM Role criada: jsmc-contact-form-lambda-role
[ ] Política SES adicionada à Role
[ ] Lambda Function criada: jsmc-contact-form-handler
[ ] Variáveis de ambiente configuradas
[ ] Timeout ajustado para 30s
[ ] Código Lambda uploaded (ZIP ou copiar/colar)
[ ] Lambda testada individualmente (opcional)
[ ] API Gateway REST API criada: jsmc-contact-form-api
[ ] Resource /contact criado
[ ] Método POST configurado
[ ] CORS habilitado
[ ] API deployada para stage "production"
[ ] URL da API copiada: https://xxxxx.../production/contact
[ ] API testada via cURL (email recebido)
```

---

### **Passo 3: Configurar API Endpoint no Frontend**

⏱️ Tempo estimado: 5 minutos

Agora que a API está funcionando, configure o website para usar a URL da API.

#### **Opção A: Editar js/config.js (RECOMENDADO)**

```bash
1. Abrir arquivo: js/config.js

2. Substituir API_ENDPOINT pela URL copiada no Passo 2:
```

```javascript
window.JSMC_CONFIG = {
    // Substituir pela URL REAL copiada no Passo 2.3
    API_ENDPOINT: 'https://abc123xyz.execute-api.us-east-1.amazonaws.com/production/contact',

    ENVIRONMENT: 'production',
    VERSION: '11.0.0'
};
```

```bash
3. Salvar arquivo
```

#### **Opção B: Adicionar inline no HTML (Alternativa)**

Se preferir não mexer em arquivos JS:

```bash
1. Abrir: index.html

2. Localizar: <script src="js/config.js"></script>

3. SUBSTITUIR por:
```

```html
<script>
  window.JSMC_CONFIG = {
    API_ENDPOINT: 'https://abc123xyz.execute-api.us-east-1.amazonaws.com/production/contact',
    ENVIRONMENT: 'production',
    VERSION: '11.0.0'
  };
</script>
```

---

### **Passo 4: Testar Localmente (Opcional)**

⏱️ Tempo estimado: 3 minutos

Antes de fazer deploy, teste no seu computador:

```bash
1. Abrir terminal no diretório do projeto:
   cd /caminho/para/jsmc-website

2. Iniciar servidor local:
   # Opção A - Python 3:
   python3 -m http.server 8080

   # Opção B - Python 2:
   python -m SimpleHTTPServer 8080

   # Opção C - Node.js (se tiver http-server instalado):
   npx http-server -p 8080

3. Abrir navegador:
   http://localhost:8080

4. Ir para seção "Contato"

5. Preencher e enviar formulário

6. Verificar:
   ✅ Botão muda para "✓ Mensagem enviada com sucesso!"
   ✅ Formulário é limpo
   ✅ Email chega em informacoes@jsmc.com.br

7. Parar servidor: Ctrl+C
```

---

### **Passo 5: Deploy do Website**

⏱️ Tempo estimado: 2 minutos

Fazer deploy das alterações para produção:

```bash
1. Verificar mudanças:
   git status

2. Adicionar arquivos modificados:
   git add js/config.js
   # ou se usou Opção B:
   git add index.html

3. Commit:
   git commit -m "config: adicionar API endpoint do formulário de contato"

4. Push para deploy automático:
   git push origin develop
   # ou main, dependendo do seu branch principal

5. Aguardar GitHub Actions (1-2 minutos)
   - Ver progresso em: https://github.com/seu-repo/actions

6. Após sucesso, aguardar invalidação CloudFront (1-5 minutos)
```

---

### **Passo 6: Testar em Produção**

⏱️ Tempo estimado: 5 minutos

Teste o formulário no website em produção:

#### **Teste Completo:**

```bash
1. Acessar: https://jsmc.com.br

2. Scroll até seção "Entre em Contato"

3. Preencher formulário:
   Nome: Teste Produção
   Email: fagner.silva@jsmc.com.br
   Empresa: JSMC Soluções
   Assunto: Consultoria em Energia
   Mensagem: Teste do formulário em produção.

4. Clicar: "Enviar Mensagem"

5. Verificar comportamento:
   ✅ Botão muda para "Enviando..."
   ✅ Botão desabilitado durante envio
   ✅ Após 1-2 segundos: "✓ Mensagem enviada com sucesso!"
   ✅ Botão fica verde
   ✅ Formulário é limpo automaticamente
   ✅ Após 3 segundos, botão volta ao normal

6. Verificar email:
   ✅ Abrir Office 365: informacoes@jsmc.com.br
   ✅ Email deve ter chegado com:
      - Assunto: [Website] Consultoria em Energia - Teste Produção
      - De: noreply@jsmc.com.br
      - Para: informacoes@jsmc.com.br
      - Conteúdo formatado em HTML bonito

7. Verificar lista de distribuição:
   ✅ Email também chegou em fagner.silva@jsmc.com.br
   ✅ Email também chegou em joao.souza@jsmc.com.br
```

#### **Teste de Erro (Opcional):**

```bash
1. Desabilitar internet do computador momentaneamente

2. Tentar enviar formulário

3. Verificar:
   ✅ Aparece mensagem de erro
   ✅ Botão fica vermelho: "✗ Erro ao enviar. Tente novamente."
   ✅ Alert com mensagem amigável e contato alternativo

4. Reabilitar internet
```

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
