# 📧 Lambda Function - Contact Form Handler

Função AWS Lambda para processar formulário de contato do website JSMC Soluções.

## 📁 Arquivos

- **contact-form-handler.js** - Handler principal da Lambda
- **package.json** - Dependências Node.js

## 🚀 Deploy

### Deploy Manual

```bash
cd lambda
npm install
zip -r function.zip .
aws lambda update-function-code \
  --function-name jsmc-contact-form-handler-production \
  --zip-file fileb://function.zip
```

### Deploy Automático (GitHub Actions)

O deploy é automático quando há mudanças na pasta `lambda/`:

```bash
git add lambda/
git commit -m "feat: atualizar Lambda function"
git push origin develop  # ou main
```

## 🔧 Variáveis de Ambiente

Configuradas via CloudFormation:

- **FROM_EMAIL** - Email remetente (verificado no SES)
- **TO_EMAIL** - Email destinatário
- **BCC_EMAIL** - Cópia oculta (opcional)
- **AWS_REGION** - Região AWS
- **ENVIRONMENT** - Ambiente (production, staging, development)

## 📊 Monitoramento

### CloudWatch Logs

```bash
# Ver logs em tempo real
aws logs tail /aws/lambda/jsmc-contact-form-handler-production --follow

# Buscar erros
aws logs filter-log-events \
  --log-group-name /aws/lambda/jsmc-contact-form-handler-production \
  --filter-pattern "ERROR"
```

### Testar Localmente

```bash
node -e "
const handler = require('./contact-form-handler');
handler.handler({
  httpMethod: 'POST',
  body: JSON.stringify({
    name: 'Teste Local',
    email: 'teste@example.com',
    subject: 'consultoria',
    message: 'Mensagem de teste'
  })
}).then(console.log);
"
```

## 🧪 Testes

```bash
# Testar Lambda via AWS CLI
aws lambda invoke \
  --function-name jsmc-contact-form-handler-production \
  --payload '{"httpMethod":"POST","body":"{\"name\":\"Test\",\"email\":\"test@jsmc.com.br\",\"subject\":\"consultoria\",\"message\":\"Teste\"}"}' \
  response.json

cat response.json
```

## 📝 Formato dos Dados

### Request

```json
{
  "name": "João Silva",
  "email": "joao@example.com",
  "company": "Empresa XYZ",
  "subject": "consultoria",
  "message": "Gostaria de saber mais sobre..."
}
```

### Response (Sucesso)

```json
{
  "statusCode": 200,
  "body": {
    "success": true,
    "message": "Mensagem enviada com sucesso!"
  }
}
```

### Response (Erro)

```json
{
  "statusCode": 400,
  "body": {
    "error": "Dados inválidos",
    "details": ["Nome inválido", "Email inválido"]
  }
}
```

## 🔐 Segurança

- ✅ Validação de inputs
- ✅ Escape HTML (prevenção XSS)
- ✅ Rate limiting via API Gateway
- ✅ CORS configurado
- ✅ IAM Role com privilégio mínimo

## 📖 Documentação Completa

Ver [CONTACT-FORM-SETUP.md](../CONTACT-FORM-SETUP.md) para guia completo de setup.
