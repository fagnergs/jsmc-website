# 🚀 Guia de Publicação - JSMC Soluções Website

## Sumário
1. [Pré-requisitos](#pré-requisitos)
2. [Configuração Inicial](#configuração-inicial)
3. [Setup AWS](#setup-aws)
4. [Configuração GitHub Actions](#configuração-github-actions)
5. [Deploy](#deploy)
6. [Monitoramento](#monitoramento)

---

## ✅ Pré-requisitos

### Ferramentas Necessárias
- **AWS CLI v2+**: [Download](https://aws.amazon.com/cli/)
- **Node.js 18+**: [Download](https://nodejs.org/)
- **Git**: [Download](https://git-scm.com/)
- **Docker** (opcional): [Download](https://www.docker.com/)

### Contas e Acessos
- Conta AWS com permissões administrativas
- Repositório GitHub privado/público
- DNS configurado com Microsoft (compatível com AWS)
- Certificado SSL/TLS no ACM (AWS Certificate Manager)

---

## 🔧 Configuração Inicial

### 1. Clonar o Repositório
```bash
git clone https://github.com/JSMC-Solucoes/website.git
cd website
```

### 2. Instalar Dependências
```bash
npm install
npm run lint
```

### 3. Teste Local
```bash
# Servidor local na porta 8080
npm start

# Ou com servidor Python alternativo
python -m http.server 8080
```

Acesse: `http://localhost:8080`

---

## 🏗️ Setup AWS

### 1. Criar Certificado SSL/TLS no ACM
```bash
# Verificar se certificado já existe
aws acm list-certificates --region us-east-1

# Se não existir, criar novo certificado
aws acm request-certificate \
  --domain-name jsmc.com.br \
  --subject-alternative-names www.jsmc.com.br \
  --validation-method DNS \
  --region us-east-1
```

**Anote o ARN do certificado** - você precisará depois.

### 2. Validar Domínio
- Acesse AWS ACM Console
- Clique no certificado criado
- Anote os registros DNS de validação (CNAME)
- Adicione esses registros ao seu DNS Microsoft

### 3. Implantar Stack CloudFormation

```bash
# Define variáveis de ambiente
export CERTIFICATE_ARN="arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/xxxxx"
export DOMAIN_NAME="jsmc.com.br"
export GITHUB_REPO="JSMC-Solucoes/website"

# Deploy da stack (primeira vez)
aws cloudformation create-stack \
  --stack-name jsmc-website-stack \
  --template-body file://aws-infrastructure.yaml \
  --parameters \
    ParameterKey=DomainName,ParameterValue=${DOMAIN_NAME} \
    ParameterKey=CertificateArn,ParameterValue=${CERTIFICATE_ARN} \
    ParameterKey=GitHubRepo,ParameterValue=${GITHUB_REPO} \
  --capabilities CAPABILITY_IAM \
  --region us-east-1

# Aguardar conclusão (pode levar 5-10 min)
aws cloudformation wait stack-create-complete \
  --stack-name jsmc-website-stack \
  --region us-east-1

# Obter outputs
aws cloudformation describe-stacks \
  --stack-name jsmc-website-stack \
  --region us-east-1 \
  --query 'Stacks[0].Outputs'
```

### 4. Obter Informações Necessárias
```bash
# Salvar outputs em variáveis
STACK_NAME="jsmc-website-stack"
REGION="us-east-1"

# S3 Bucket
S3_BUCKET=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $REGION \
  --query 'Stacks[0].Outputs[?OutputKey==`S3BucketName`].OutputValue' \
  --output text)

# CloudFront Distribution ID
CF_DIST_ID=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $REGION \
  --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontDistributionId`].OutputValue' \
  --output text)

echo "S3 Bucket: $S3_BUCKET"
echo "CloudFront ID: $CF_DIST_ID"
```

### 5. Configurar DNS (Microsoft/Office 365)
Adicione os registros no painel Microsoft:

```
CNAME Record:
Host: @
Points to: d123abc.cloudfront.net
TTL: 1 hora (ou menor)

CNAME Record (www):
Host: www
Points to: d123abc.cloudfront.net
TTL: 1 hora
```

**Tempo de propagação**: 5-48 horas

---

## 🔐 Configuração GitHub Actions

### 1. Criar OIDC Provider (sem credenciais estáticas)

```bash
# O stack CloudFormation já configura isso automaticamente
# Verifique:
aws iam list-open-id-connect-providers --region us-east-1
```

### 2. Adicionar Secrets ao GitHub

Acesse: `Settings > Secrets and variables > Actions`

Adicione os seguintes secrets:

```
AWS_ROLE_ARN
  Valor: arn:aws:iam::ACCOUNT_ID:role/GitHubActionsRole
  (Obtém da saída do CloudFormation ou via AWS Console)

AWS_S3_BUCKET
  Valor: jsmc-website-xxxxx
  (Nome do bucket S3 criado)

AWS_CLOUDFRONT_ID
  Valor: D1A2B3C4D5E6
  (Distribution ID do CloudFront)

SLACK_WEBHOOK (opcional)
  Valor: https://hooks.slack.com/services/xxxxx
  (Para notificações de deploy)
```

### 3. Verificar Credenciais AWS CLI Localmente

```bash
# Verificar configuração
aws sts get-caller-identity

# Resultado esperado:
# {
#     "UserId": "...",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/..."
# }
```

---

## 🚀 Deploy

### Opção 1: Deploy Automático via GitHub (Recomendado)

```bash
# 1. Fazer commit de qualquer mudança
git add .
git commit -m "Atualização de conteúdo"
git push origin main

# 2. GitHub Actions executará automaticamente:
#    - Build
#    - Testes
#    - Upload para S3
#    - Invalidação CloudFront
#    - Notificação Slack (opcional)
```

**Tempo total**: < 30 segundos ⚡

### Opção 2: Deploy Manual Local

```bash
# Configurar variáveis
export AWS_S3_BUCKET="jsmc-website-xxxxx"
export AWS_CLOUDFRONT_ID="D1A2B3C4D5E6"
export AWS_REGION="us-east-1"

# Build local
npm run build

# Upload para S3
aws s3 sync build/ s3://${AWS_S3_BUCKET}/ \
  --delete \
  --region ${AWS_REGION} \
  --cache-control "public, max-age=31536000" \
  --exclude "index.html" \
  --exclude "*.json"

aws s3 cp build/index.html s3://${AWS_S3_BUCKET}/index.html \
  --cache-control "public, max-age=3600" \
  --content-type "text/html; charset=utf-8" \
  --region ${AWS_REGION}

# Invalidar CloudFront
aws cloudfront create-invalidation \
  --distribution-id ${AWS_CLOUDFRONT_ID} \
  --paths "/*" \
  --region ${AWS_REGION}

echo "✅ Deploy concluído!"
echo "📍 URL: https://jsmc.com.br"
```

### Opção 3: Deploy via Docker (Isolado)

```bash
# Build imagem Docker
docker build -t jsmc-website:latest .

# Run container
docker run -it --rm \
  -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
  -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
  -v $(pwd):/app \
  jsmc-website:latest \
  npm run build && npm run deploy

echo "✅ Deploy completo!"
```

---

## 📊 Monitoramento

### Verificar Status do Website

```bash
# Teste de conectividade
curl -I https://jsmc.com.br

# Verificar headers HTTP
curl -v https://jsmc.com.br 2>&1 | grep -i "server\|cache\|content"

# Teste com curl completo
time curl -o /dev/null -s -w "%{http_code}" https://jsmc.com.br
```

### CloudWatch Monitoring

```bash
# Ver logs de CloudFront
aws logs tail /aws/jsmc-website --follow --region us-east-1

# Métricas do S3
aws s3api get-bucket-metrics-configuration \
  --bucket jsmc-website-xxxxx

# Distribuição CloudFront
aws cloudfront get-distribution-statistics \
  --id D1A2B3C4D5E6
```

### Lighthouse Performance Check

```bash
# Teste local
npm run lighthouse

# Resultado esperado:
# Performance: 90+
# Accessibility: 95+
# Best Practices: 95+
# SEO: 100
```

---

## 🔧 Troubleshooting

### Problema: "Permission Denied" ao fazer deploy

**Solução:**
```bash
# Verificar credenciais AWS
aws sts get-caller-identity

# Verificar permissões IAM
aws iam get-user

# Reconfigurar credenciais
aws configure
```

### Problema: CloudFront ainda mostra cache antigo

**Solução:**
```bash
# Forçar invalidação completa
aws cloudfront create-invalidation \
  --distribution-id D1A2B3C4D5E6 \
  --paths "/*"

# Aguardar (2-5 min)
# Limpar cache do navegador (Ctrl+Shift+Del)
```

### Problema: DNS não resolve

**Solução:**
```bash
# Verificar propagação DNS
nslookup jsmc.com.br

# Limpar cache DNS local
ipconfig /flushdns  # Windows
sudo dscacheutil -flushcache  # macOS
sudo systemctl restart nscd  # Linux

# Aguardar 24-48 horas para propagação completa
```

### Problema: HTTPS não funciona

**Solução:**
```bash
# Verificar certificado
aws acm describe-certificate \
  --certificate-arn arn:aws:acm:us-east-1:xxxx:certificate/yyyy

# Status esperado: "SUCCESS" em ValidationStatus
# Se "PENDING": validar domínio via DNS/Email no ACM Console
```

---

## 📋 Checklist Pós-Deploy

- [ ] Website acessível em https://jsmc.com.br
- [ ] HTTPS funcionando (certificado válido)
- [ ] Redirecionamento de http → https
- [ ] WWW redirecionando para domínio principal
- [ ] Performance > 90 (Lighthouse)
- [ ] Todos os links funcionando
- [ ] Formulário de contato testado
- [ ] Imagens carregando corretamente
- [ ] Responsivo em dispositivos móveis
- [ ] Analytics configurados (se aplicável)

---

## 📞 Suporte e Contatos

**Problemas com infraestrutura AWS?**
- Abra um issue no GitHub
- Contato: informacoes@jsmc.com.br
- Telefone: +55 11 92002-9999

**Documentação referências:**
- [AWS S3](https://docs.aws.amazon.com/s3/)
- [CloudFront](https://docs.aws.amazon.com/cloudfront/)
- [ACM Certificates](https://docs.aws.amazon.com/acm/)
- [GitHub Actions](https://docs.github.com/en/actions)

---

**Última atualização**: Dezembro 2024
**Versão**: 1.0.0
**Status**: Production Ready ✅
