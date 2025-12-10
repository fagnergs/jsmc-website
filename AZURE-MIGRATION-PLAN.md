# 📋 PLANO DE MIGRAÇÃO AWS → AZURE - JSMC Soluções Website

<div align="center">

**Guia Completo para Migração de Infraestrutura**

[![Azure](https://img.shields.io/badge/Azure-Storage%20%7C%20CDN-0078D4.svg)](https://azure.microsoft.com)
[![Status](https://img.shields.io/badge/status-planejamento-yellow.svg)](.)

**Migração de AWS para Microsoft Azure**

</div>

---

## 📋 Índice

1. [Visão Geral da Migração](#visão-geral-da-migração)
2. [Comparação AWS vs Azure](#comparação-aws-vs-azure)
3. [Arquitetura Azure Proposta](#arquitetura-azure-proposta)
4. [Recursos Azure Necessários](#recursos-azure-necessários)
5. [Estrutura de Branches](#estrutura-de-branches)
6. [Estratégia de Migração](#estratégia-de-migração)
7. [Controle FinOps](#controle-finops)
8. [Cronograma](#cronograma)
9. [Riscos e Mitigação](#riscos-e-mitigação)

---

## 🎯 Visão Geral da Migração

### Objetivos da Migração

```
✅ Migrar site estático de AWS para Azure
✅ Manter funcionalidade de formulário de contato (email)
✅ Implementar nova seção "Institucional"
✅ Preservar CI/CD com GitHub Actions
✅ Controle completo de FinOps
✅ Infraestrutura via CLI (automatizada)
✅ Testar completamente antes de switch de DNS
```

### Escopo da Migração

```yaml
Atual (AWS):
  - S3 Bucket (static hosting)
  - CloudFront (CDN + HTTPS)
  - ACM (SSL/TLS Certificate)
  - Lambda (contact form handler)
  - SES (email sending)
  - Route 53 ou DNS Externo
  - GitHub Actions (CI/CD)

Futuro (Azure):
  - Azure Storage Account (static website)
  - Azure CDN (Verizon/Microsoft Premium)
  - Azure Key Vault (SSL certificate)
  - Azure Functions (contact form handler)
  - Azure Communication Services ou SendGrid (email)
  - Azure DNS
  - GitHub Actions (CI/CD atualizado)

Novo:
  - Seção "Institucional" no website
  - Links para downloads
  - Vídeos embarcados
```

---

## 🔄 Comparação AWS vs Azure

### Mapeamento de Serviços

| Função | AWS | Azure | Observações |
|--------|-----|-------|-------------|
| **Static Hosting** | S3 | Azure Storage (Static Website) | Equivalente direto |
| **CDN** | CloudFront | Azure CDN / Front Door | Front Door recomendado |
| **SSL/TLS** | ACM | Azure Key Vault + Managed Cert | Certificado gerenciado |
| **Serverless Functions** | Lambda | Azure Functions | Node.js runtime |
| **Email Service** | SES | Communication Services / SendGrid | SendGrid marketplace |
| **DNS** | Route 53 / Externo | Azure DNS | Migração gradual |
| **Monitoring** | CloudWatch | Azure Monitor | Logs e métricas |
| **Secrets** | Secrets Manager | Key Vault | Credenciais seguras |
| **CI/CD** | GitHub Actions + OIDC | GitHub Actions + OIDC | Manter estrutura |

### Comparação de Custos (Estimativa)

```
┌──────────────────────────────────────────────────────┐
│              COMPARAÇÃO DE CUSTOS MENSAIS            │
├──────────────────────────────────────────────────────┤
│                                                      │
│  AWS (Atual):                                        │
│    S3 Storage (1 GB):           $1-2                 │
│    CloudFront (10 GB):          $5-10                │
│    Lambda (1K invocations):     <$1                  │
│    SES (100 emails):            <$1                  │
│    Total AWS:                   $10-15/mês           │
│                                                      │
│  Azure (Futuro):                                     │
│    Storage Account (1 GB):      $1-2                 │
│    Azure CDN/Front Door:        $5-15                │
│    Functions (1K exec):         <$1                  │
│    SendGrid (100 emails):       FREE tier            │
│    DNS Zone:                    $0.50/zone           │
│    Total Azure:                 $10-20/mês           │
│                                                      │
│  Economia/Custo Similar:        0-10% variação       │
│                                                      │
└──────────────────────────────────────────────────────┘

Nota: Custos variam com tráfego e região
```

---

## 🏗️ Arquitetura Azure Proposta

### Diagrama de Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                  USUÁRIO / NAVEGADOR                            │
│               (Desktop / Mobile / Tablet)                       │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            │ HTTPS (TLS 1.2+)
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Azure DNS - jsmc.com.br                       │
│              (Name Servers: ns1-XX.azure-dns.com)               │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            │ CNAME → Azure Front Door
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│              Azure Front Door Premium                           │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ • Endpoint: jsmc-xxxxx.azurefd.net                     │    │
│  │ • SSL/TLS: Managed Certificate (Let's Encrypt)         │    │
│  │ • WAF: Standard rules enabled                          │    │
│  │ • Caching: Optimized for static content                │    │
│  │ • Compression: gzip, brotli                            │    │
│  │ • HTTP/2 + HTTP/3 enabled                              │    │
│  │ • Global edge locations: 100+ POPs                     │    │
│  └────────────────────────────────────────────────────────┘    │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            │ Origin: Storage Account
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│              Azure Storage Account                              │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ Name: jsmcwebsite                                      │    │
│  │ Type: StorageV2 (general purpose v2)                   │    │
│  │ Static Website: Enabled                                │    │
│  │ Replication: LRS (Locally Redundant)                   │    │
│  │ Blob Container: $web (public blob)                     │    │
│  │ Index Document: index.html                             │    │
│  │ 404 Document: 404.html                                 │    │
│  │ HTTPS Only: Enabled                                    │    │
│  └────────────────────────────────────────────────────────┘    │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            │ Deploy via Azure CLI
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                  GitHub Actions (CI/CD)                         │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ Workflow: deploy-azure.yml                             │    │
│  │ Trigger: push to jsmc-azure branch                     │    │
│  │ Auth: OIDC (Azure Service Principal)                   │    │
│  │ Steps:                                                 │    │
│  │   1. Checkout code                                     │    │
│  │   2. Azure Login (OIDC)                                │    │
│  │   3. Upload to $web container                          │    │
│  │   4. Purge Azure Front Door cache                      │    │
│  │ Duration: <30 segundos                                 │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│         COMPONENTES ADICIONAIS (Formulário de Contato)         │
│                                                                 │
│  Form POST → Azure Functions → SendGrid → Email                │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ HTTP Trigger │→ │Azure Function│→ │   SendGrid   │         │
│  │ (Consumption)│  │ (Node.js 18) │  │  (Email API) │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                NOVA SEÇÃO: INSTITUCIONAL                        │
│                                                                 │
│  • Descrição da empresa                                        │
│  • Links para downloads (PDFs em Blob Storage)                 │
│  • Vídeos embarcados (YouTube/Vimeo)                           │
│  • Design consistente com site atual                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## ☁️ Recursos Azure Necessários

### 1. Resource Group

```bash
# Resource Group principal
Name: rg-jsmc-website-prod
Location: Brazil South (São Paulo)
Tags:
  - Environment: Production
  - Project: JSMC Website
  - ManagedBy: Terraform/CLI
  - CostCenter: JSMC-Marketing
```

### 2. Storage Account

```bash
Name: jsmcwebsite (global único)
Location: Brazil South
Performance: Standard
Replication: LRS (Locally Redundant Storage)
Account Kind: StorageV2
Access Tier: Hot
Static Website: Enabled
  - Index document: index.html
  - Error document: 404.html
Blob public access: Enabled (somente $web container)
HTTPS only: Enabled
Minimum TLS: 1.2
```

### 3. Azure Front Door (Premium)

```bash
Name: fd-jsmc-website
SKU: Premium (inclui WAF)
Endpoint: jsmc-website-xxxxx.azurefd.net
Custom Domain: jsmc.com.br, www.jsmc.com.br

Origin Group:
  - Name: storage-origin
  - Origin: jsmcwebsite.z15.web.core.windows.net
  - Origin host header: jsmcwebsite.z15.web.core.windows.net
  - Priority: 1
  - Weight: 1000

Routes:
  - Path: /*
  - Supported protocols: HTTP, HTTPS
  - Redirect: HTTP → HTTPS
  - Caching: Enabled
  - Query string caching: Use Query String
  - Compression: Enabled (gzip, brotli)

Security:
  - Managed Certificate: Enabled (Let's Encrypt)
  - TLS version: 1.2 minimum
  - WAF Policy: Basic protection
```

### 4. Azure Functions (Formulário)

```bash
Function App Name: func-jsmc-contact-form
Runtime: Node.js 18 LTS
Hosting Plan: Consumption (Y1)
Storage Account: jsmcwebsitestorage
Application Insights: Enabled

Environment Variables:
  - SENDGRID_API_KEY: (Key Vault reference)
  - FROM_EMAIL: informacoes@jsmc.com.br
  - TO_EMAIL: informacoes@jsmc.com.br
  - CORS_ORIGINS: https://jsmc.com.br

Function:
  - Name: ContactFormHandler
  - Trigger: HTTP POST
  - Auth Level: Anonymous (com validação CORS)
  - URL: https://func-jsmc-contact-form.azurewebsites.net/api/contact
```

### 5. SendGrid (Email)

```bash
# Via Azure Marketplace
Plan: Free (100 emails/day)
Upgrade: Essentials ($15/mês para 40K emails)

API Key: Armazenado no Key Vault
Integration: Via Azure Functions
```

### 6. Azure Key Vault

```bash
Name: kv-jsmc-website
Location: Brazil South
SKU: Standard
Access policies: Azure Functions (Get Secret)

Secrets:
  - sendgrid-api-key
  - github-pat (se necessário)
```

### 7. Azure DNS

```bash
Zone Name: jsmc.com.br
Resource Group: rg-jsmc-website-prod
Name Servers: 
  - ns1-XX.azure-dns.com
  - ns2-XX.azure-dns.net
  - ns3-XX.azure-dns.org
  - ns4-XX.azure-dns.info

Records:
  @ (root):
    - Type: A (Alias to Front Door)
    - TTL: 3600
  
  www:
    - Type: CNAME (Front Door endpoint)
    - TTL: 3600
```

### 8. Azure Monitor

```bash
Log Analytics Workspace:
  - Name: law-jsmc-website
  - Location: Brazil South
  - Retention: 30 days

Application Insights:
  - Name: appi-jsmc-website
  - Connected to: Functions, Front Door
  
Alerts:
  - High error rate (Functions)
  - CDN cache miss rate
  - Budget threshold (80% of $30/month)
```

---

## 🌿 Estrutura de Branches

### Estratégia de Branches

```
main (AWS Production)
  │
  ├── copilot/gather-project-technical-info (atual)
  │
  └── jsmc-azure (NOVA BRANCH)
      │
      ├── azure-infrastructure/ (Bicep/CLI scripts)
      ├── azure-docs/ (documentação)
      ├── .github/workflows/deploy-azure.yml
      └── institucional/ (nova seção)
```

### Fluxo de Trabalho

```
1. Criar branch jsmc-azure a partir de main
2. Desenvolver infraestrutura Azure
3. Implementar seção Institucional
4. Testar em staging (Azure)
5. Validar completamente
6. Merge para main
7. Switch DNS de AWS → Azure
8. Manter AWS por 30 dias (rollback)
9. Desprovisionar AWS após confirmação
```

### Comandos Git

```bash
# Criar nova branch
git checkout main
git pull origin main
git checkout -b jsmc-azure
git push origin jsmc-azure

# Proteger branch no GitHub
# Settings > Branches > Add rule
# Branch name pattern: jsmc-azure
# Require pull request reviews before merging
# Require status checks to pass
```

---

## 🚀 Estratégia de Migração

### Fase 1: Preparação (Semana 1)

**Objetivos:**
- ✅ Criar documentação completa
- ✅ Provisionar tenant Azure JSMC
- ✅ Criar branch jsmc-azure
- ✅ Configurar GitHub Actions OIDC

**Entregáveis:**
- [ ] AZURE-MIGRATION-PLAN.md (este documento)
- [ ] AZURE-INFRASTRUCTURE-GUIDE.md (guia técnico)
- [ ] AZURE-DEPLOYMENT.md (procedimentos)
- [ ] Branch jsmc-azure criada
- [ ] Service Principal configurado

### Fase 2: Infraestrutura Core (Semana 2)

**Objetivos:**
- ✅ Provisionar Storage Account
- ✅ Configurar Static Website
- ✅ Criar Azure Front Door
- ✅ Testar upload manual

**Entregáveis:**
- [ ] Resource Group criado
- [ ] Storage Account provisionado
- [ ] Site acessível via *.azurefd.net
- [ ] Scripts CLI documentados

### Fase 3: CI/CD Azure (Semana 2)

**Objetivos:**
- ✅ Configurar GitHub Actions
- ✅ Deploy automático
- ✅ Cache invalidation
- ✅ Testes automatizados

**Entregáveis:**
- [ ] deploy-azure.yml funcional
- [ ] Secrets configurados no GitHub
- [ ] Pipeline testado
- [ ] Tempo de deploy <30s

### Fase 4: Formulário de Contato (Semana 3)

**Objetivos:**
- ✅ Migrar Lambda → Azure Functions
- ✅ Configurar SendGrid
- ✅ Testar envio de emails
- ✅ Validação e segurança

**Entregáveis:**
- [ ] Function App deployada
- [ ] SendGrid integrado
- [ ] Formulário testado
- [ ] Logs no Application Insights

### Fase 5: Seção Institucional (Semana 3-4)

**Objetivos:**
- ✅ Design nova seção
- ✅ Implementar downloads
- ✅ Embeddar vídeos
- ✅ Testes responsivos

**Entregáveis:**
- [ ] HTML/CSS da seção
- [ ] Arquivos PDF no Blob Storage
- [ ] Vídeos incorporados
- [ ] Mobile-friendly

### Fase 6: DNS e SSL (Semana 4)

**Objetivos:**
- ✅ Configurar Azure DNS
- ✅ Custom domain no Front Door
- ✅ Certificado SSL/TLS
- ✅ Validação HTTPS

**Entregáveis:**
- [ ] DNS Zone criada
- [ ] Custom domain validado
- [ ] Certificado provisionado
- [ ] HTTPS funcionando

### Fase 7: Testes Completos (Semana 5)

**Objetivos:**
- ✅ Testes funcionais completos
- ✅ Testes de performance
- ✅ Testes de segurança
- ✅ Validação cross-browser

**Entregáveis:**
- [ ] Checklist de testes
- [ ] Lighthouse score 90+
- [ ] Security headers validados
- [ ] Aprovação stakeholders

### Fase 8: Go-Live (Semana 6)

**Objetivos:**
- ✅ Backup completo AWS
- ✅ Switch DNS
- ✅ Monitoramento 24h
- ✅ Comunicação clientes

**Entregáveis:**
- [ ] DNS apontando para Azure
- [ ] Site em produção Azure
- [ ] Monitoring ativo
- [ ] Runbook atualizado

### Fase 9: Pós-Migração (Semana 7-8)

**Objetivos:**
- ✅ Monitorar performance
- ✅ Ajustes finos
- ✅ Otimizações
- ✅ Desprovisionar AWS

**Entregáveis:**
- [ ] Métricas comparativas
- [ ] Ajustes realizados
- [ ] AWS desligada
- [ ] Documentação final

---

## 💰 Controle FinOps

### Estrutura de Tags

```yaml
Tags Obrigatórias (Todas os recursos):
  Environment: Production
  Project: JSMC-Website
  ManagedBy: CLI-Automation
  CostCenter: JSMC-Marketing
  Owner: JSMC-IT-Team
  Backup: Daily
  Compliance: LGPD

Tags Opcionais:
  Application: Website
  Version: 1.0.0
  CreatedDate: YYYY-MM-DD
  ExpiryDate: Never
```

### Resource Naming Convention

```
Pattern: {resource-type}-{project}-{environment}-{location}

Exemplos:
  rg-jsmc-website-prod          (Resource Group)
  jsmcwebsite                   (Storage Account - sem hífens)
  fd-jsmc-website-prod          (Front Door)
  func-jsmc-contact-prod        (Function App)
  kv-jsmc-website-prod          (Key Vault)
  appi-jsmc-website-prod        (Application Insights)
  law-jsmc-website-prod         (Log Analytics)

Padrão Microsoft:
  https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging
```

### Cost Management

```yaml
Budget:
  Name: budget-jsmc-website-monthly
  Amount: $30/month
  Alerts:
    - Threshold: 50% ($15)
      Action: Email notification
    - Threshold: 80% ($24)
      Action: Email + Slack
    - Threshold: 100% ($30)
      Action: Email + Slack + Stop deployment

Cost Analysis:
  - Frequency: Weekly
  - Grouping: By Resource Type
  - Export: CSV to Storage Account
  - Dashboard: Azure Portal + Power BI

Optimization:
  - Review unused resources monthly
  - Evaluate SKU/tier options quarterly
  - Reserved instances (1-year) evaluation
  - Spot instances for dev/test
```

### Hierarquia de Recursos

```
Management Group: JSMC-Solucoes
  │
  └── Subscription: JSMC-Production
      │
      └── Resource Group: rg-jsmc-website-prod
          │
          ├── Storage Account: jsmcwebsite
          ├── Front Door: fd-jsmc-website-prod
          ├── Function App: func-jsmc-contact-prod
          ├── Key Vault: kv-jsmc-website-prod
          ├── DNS Zone: jsmc.com.br
          ├── Log Analytics: law-jsmc-website-prod
          └── Application Insights: appi-jsmc-website-prod
```

### Políticas de Governança

```json
{
  "policies": [
    {
      "name": "Require tags",
      "effect": "Deny",
      "requiredTags": ["Environment", "Project", "CostCenter"]
    },
    {
      "name": "Allowed locations",
      "effect": "Deny",
      "locations": ["brazilsouth", "eastus2"]
    },
    {
      "name": "Allowed SKUs",
      "effect": "Audit",
      "allowedSKUs": ["Standard_LRS", "Premium_LRS"]
    },
    {
      "name": "HTTPS only",
      "effect": "Deny",
      "resources": ["Storage", "WebApps"]
    }
  ]
}
```

---

## 📅 Cronograma

```
┌─────────────────────────────────────────────────────────────┐
│                    CRONOGRAMA DE MIGRAÇÃO                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Semana 1: Preparação                                        │
│   ├─ Criar documentação                           [2 dias] │
│   ├─ Provisionar tenant Azure                     [1 dia]  │
│   ├─ Configurar Service Principal                 [1 dia]  │
│   └─ Criar branch jsmc-azure                      [1 dia]  │
│                                                             │
│ Semana 2: Infraestrutura + CI/CD                           │
│   ├─ Storage Account + Static Website             [1 dia]  │
│   ├─ Azure Front Door                              [2 dias] │
│   ├─ GitHub Actions CI/CD                         [2 dias] │
│   └─ Testes iniciais                               [1 dia]  │
│                                                             │
│ Semana 3: Functions + Institucional                        │
│   ├─ Azure Functions (formulário)                 [2 dias] │
│   ├─ SendGrid integration                         [1 dia]  │
│   ├─ Nova seção Institucional                     [3 dias] │
│   └─ Testes                                        [1 dia]  │
│                                                             │
│ Semana 4: DNS + SSL                                        │
│   ├─ Azure DNS configuration                      [1 dia]  │
│   ├─ Custom domain Front Door                     [1 dia]  │
│   ├─ SSL certificate                               [1 dia]  │
│   ├─ Testes HTTPS                                 [1 dia]  │
│   └─ Buffer                                        [1 dia]  │
│                                                             │
│ Semana 5: Testes Completos                                 │
│   ├─ Testes funcionais                            [2 dias] │
│   ├─ Performance tests                            [1 dia]  │
│   ├─ Security audit                               [1 dia]  │
│   └─ UAT (User Acceptance)                        [1 dia]  │
│                                                             │
│ Semana 6: Go-Live                                          │
│   ├─ Backup AWS                                   [1 dia]  │
│   ├─ DNS switch                                   [1 dia]  │
│   ├─ Monitoramento intensivo                      [2 dias] │
│   └─ Ajustes pós-deploy                          [1 dia]  │
│                                                             │
│ Semanas 7-8: Estabilização                                 │
│   ├─ Monitorar métricas                          [5 dias] │
│   ├─ Otimizações                                  [3 dias] │
│   └─ Desprovisionar AWS                          [2 dias] │
│                                                             │
│ TOTAL: 6-8 semanas                                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## ⚠️ Riscos e Mitigação

### Riscos Identificados

| # | Risco | Probabilidade | Impacto | Mitigação |
|---|-------|---------------|---------|-----------|
| 1 | Downtime durante DNS switch | Média | Alto | Testar completamente antes; switch em baixa demanda |
| 2 | Problemas com formulário email | Baixa | Médio | Testes extensivos; monitorar logs |
| 3 | Performance degradada | Baixa | Alto | Testes de carga; Lighthouse pre/post |
| 4 | Custos acima do esperado | Média | Médio | Budget alerts; monitoramento diário |
| 5 | Certificado SSL não provisiona | Baixa | Alto | Validar domínio antes; manual fallback |
| 6 | GitHub Actions falha | Baixa | Médio | Deploy manual como backup |
| 7 | Incompatibilidade DNS | Baixa | Alto | Testar com subdomínio primeiro |
| 8 | Rollback necessário | Baixa | Alto | Manter AWS ativo por 30 dias |

### Plano de Rollback

```yaml
Cenário 1: Problemas menores (performance, bugs)
  - Manter Azure ativo
  - Corrigir problemas
  - Não reverter DNS

Cenário 2: Problemas críticos (site down, data loss)
  1. Comunicar stakeholders imediatamente
  2. Reverter DNS para AWS (propagação 5-60min)
  3. Pausar GitHub Actions Azure
  4. Investigar causa raiz
  5. Corrigir problemas
  6. Re-testar completamente
  7. Nova tentativa de switch

Cenário 3: Rollback completo
  1. Reverter DNS para AWS
  2. Desabilitar Azure Front Door
  3. Análise pós-mortem
  4. Replanejar migração
  5. Manter AWS permanentemente (ou migração futura)

TTL DNS: Reduzir para 300s (5 min) antes do switch
Janela de manutenção: Sábado 22h-02h (baixo tráfego)
Comunicação: Email clientes 48h antes
```

### Checklist de Segurança

```
[ ] HTTPS only em todos os recursos
[ ] TLS 1.2 minimum
[ ] WAF enabled no Front Door
[ ] Storage Account: HTTPS only, no public access
[ ] Functions: CORS configurado corretamente
[ ] Key Vault: Access policies restrictivas
[ ] Secrets: Nunca em código, sempre Key Vault
[ ] Service Principal: Least privilege
[ ] Network: Private endpoints (opcional)
[ ] Monitoring: Alerts configurados
[ ] Backup: Enabled com retention 30 dias
[ ] LGPD: Compliance verificada
```

---

## 📞 Contatos e Suporte

### Equipe do Projeto

```yaml
Product Owner: (Definir)
Tech Lead: Fagner Silva
DevOps: (Definir)
Azure Architect: (Consultor externo se necessário)

Comunicação:
  - Daily: Slack #jsmc-azure-migration
  - Semanal: Status meeting (Sextas 14h)
  - Emergências: Email + Telefone
```

### Suporte Microsoft

```yaml
Azure Support Plan: Developer ($29/mês)
  - Response time: 8 horas (business hours)
  - Casos ilimitados
  - Suporte técnico

Premier Support (opcional): $300+/mês
  - Response time: 1 hora crítico
  - Designated Support Engineer
  - Advisory services
```

---

## 📚 Próximos Documentos

Este é o documento principal de planejamento. Os seguintes documentos serão criados:

1. **AZURE-INFRASTRUCTURE-GUIDE.md**
   - Comandos CLI completos
   - Scripts de provisionamento
   - Configurações detalhadas

2. **AZURE-DEPLOYMENT.md**
   - Procedimentos passo-a-passo
   - GitHub Actions setup
   - Troubleshooting

3. **INSTITUCIONAL-SECTION.md**
   - Design da nova seção
   - Especificações técnicas
   - Assets necessários

4. **AZURE-FINOPS-GUIDE.md**
   - Dashboards de custo
   - Políticas de governança
   - Optimization best practices

---

<div align="center">

**Documento criado em 10 de Dezembro de 2024**

**Versão 1.0.0 - Draft**

[![Status](https://img.shields.io/badge/status-planejamento-yellow.svg)](.)
[![Azure](https://img.shields.io/badge/Azure-Migration-0078D4.svg)](https://azure.microsoft.com)

**Preparado para JSMC Soluções**

[📧 Email](mailto:informacoes@jsmc.com.br) • [🌐 Website](https://jsmc.com.br) • [💻 GitHub](https://github.com/JSMC-Solucoes/website)

</div>

---

**© 2024 JSMC Soluções. Documento Confidencial.**
