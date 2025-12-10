# 🚀 GUIA RÁPIDO - Migração Azure JSMC

<div align="center">

**Quick Start Guide - Azure Migration**

[![Azure](https://img.shields.io/badge/Azure-Ready-0078D4.svg)](.)
[![Status](https://img.shields.io/badge/status-documentação%20completa-brightgreen.svg)](.)

</div>

---

## 📚 Documentação Disponível

Toda a documentação necessária para a migração foi criada:

| Documento | Tamanho | Linhas | Descrição |
|-----------|---------|--------|-----------|
| **AZURE-MIGRATION-PLAN.md** | 25KB | 845 | Plano estratégico completo |
| **AZURE-INFRASTRUCTURE-GUIDE.md** | 23KB | 924 | Comandos CLI e scripts |
| **INSTITUCIONAL-SECTION.md** | 19KB | 724 | Design nova seção |
| **TECHNICAL-INFO.md** | 53KB | 1,795 | Info técnica completa |
| **.github/workflows/deploy-azure.yml** | 2.4KB | 71 | CI/CD workflow |

**Total:** ~122KB de documentação técnica

---

## ⚡ Início Rápido (5 Passos)

### 1️⃣ Preparação (10 min)

```bash
# Instalar Azure CLI (se necessário)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login
az login

# Definir subscription
az account set --subscription "JSMC-Production"

# Clonar configurações
cd /home/runner/work/jsmc-website/jsmc-website
source azure-config.sh  # Criar este arquivo baseado no guia
```

### 2️⃣ Criar Branch (2 min)

```bash
# Criar branch jsmc-azure
git checkout main
git pull origin main
git checkout -b jsmc-azure
git push origin jsmc-azure

# Proteger branch no GitHub
# Settings > Branches > Add rule: jsmc-azure
```

### 3️⃣ Provisionar Infraestrutura (30-45 min)

```bash
# Opção A: Script automatizado (recomendado)
chmod +x provision-all.sh
./provision-all.sh

# Opção B: Passo-a-passo manual
# Seguir AZURE-INFRASTRUCTURE-GUIDE.md seção "Provisionamento"
```

### 4️⃣ Configurar GitHub (10 min)

```bash
# Criar Service Principal
az ad sp create-for-rbac --name sp-github-jsmc \
  --role Contributor \
  --scopes /subscriptions/{id}/resourceGroups/rg-jsmc-website-prod \
  --sdk-auth

# Adicionar no GitHub:
# Settings > Secrets > Actions
# AZURE_CLIENT_ID
# AZURE_TENANT_ID
# AZURE_SUBSCRIPTION_ID
```

### 5️⃣ Primeiro Deploy (5 min)

```bash
# Push para jsmc-azure
git add .
git commit -m "feat: initial Azure infrastructure"
git push origin jsmc-azure

# GitHub Actions executará automaticamente!
# Acompanhar em: Actions tab no GitHub
```

---

## 📋 Checklist Completo

### Fase 1: Preparação ⏱️ 1 semana

```
[ ] Ler AZURE-MIGRATION-PLAN.md completamente
[ ] Ler AZURE-INFRASTRUCTURE-GUIDE.md
[ ] Instalar Azure CLI
[ ] Criar/acessar tenant Azure
[ ] Criar subscription (ou usar existente)
[ ] Configurar billing alerts
[ ] Criar branch jsmc-azure
```

### Fase 2: Infraestrutura ⏱️ 1 semana

```
[ ] Executar provision-all.sh
[ ] Verificar todos recursos criados
[ ] Configurar Front Door endpoints
[ ] Configurar custom domain
[ ] Validar SSL/TLS
[ ] Upload teste para Storage
```

### Fase 3: CI/CD ⏱️ 3 dias

```
[ ] Criar Service Principal
[ ] Configurar GitHub Secrets
[ ] Testar deploy-azure.yml workflow
[ ] Validar cache purge
[ ] Ajustar se necessário
```

### Fase 4: Formulário ⏱️ 1 semana

```
[ ] Migrar código Lambda → Functions
[ ] Configurar SendGrid
[ ] Adicionar API key no Key Vault
[ ] Configurar CORS
[ ] Testar envio de emails
[ ] Monitorar Application Insights
```

### Fase 5: Seção Institucional ⏱️ 1 semana

```
[ ] Implementar HTML (INSTITUCIONAL-SECTION.md)
[ ] Implementar CSS responsivo
[ ] Preparar PDFs (otimizados)
[ ] Upload PDFs para Blob Storage
[ ] Configurar vídeos (YouTube/Vimeo)
[ ] Adicionar embed codes
[ ] Testar downloads e vídeos
[ ] Validar mobile/desktop
```

### Fase 6: DNS + SSL ⏱️ 3-5 dias

```
[ ] Criar DNS Zone no Azure
[ ] Obter Name Servers
[ ] Atualizar NS no registrador (aguardar 24-48h)
[ ] Validar propagação DNS
[ ] Configurar custom domain no Front Door
[ ] Aguardar certificado SSL (automático)
[ ] Validar HTTPS
```

### Fase 7: Testes ⏱️ 1 semana

```
[ ] Testes funcionais completos
[ ] Lighthouse score 90+
[ ] Cross-browser testing
[ ] Testes de carga
[ ] Security audit
[ ] Validação stakeholders
```

### Fase 8: Go-Live ⏱️ 2-3 dias

```
[ ] Backup completo AWS
[ ] Reduzir TTL DNS (300s)
[ ] Comunicar clientes (48h antes)
[ ] Janela de manutenção: Sábado 22h
[ ] Switch DNS para Azure
[ ] Monitoramento 24h
[ ] Validar métricas
[ ] Rollback se necessário
```

### Fase 9: Pós-Migração ⏱️ 2 semanas

```
[ ] Monitorar performance
[ ] Comparar métricas AWS vs Azure
[ ] Ajustes finos
[ ] Otimizações
[ ] Manter AWS 30 dias (rollback)
[ ] Desprovisionar AWS
[ ] Documentação final
```

---

## 📞 Suporte e Referências

### Documentos Principais

1. **AZURE-MIGRATION-PLAN.md**
   - Estratégia completa
   - Arquitetura
   - Cronograma
   - Custos

2. **AZURE-INFRASTRUCTURE-GUIDE.md**
   - Comandos CLI
   - Scripts automatizados
   - Troubleshooting

3. **INSTITUCIONAL-SECTION.md**
   - Design e layout
   - HTML/CSS
   - Assets necessários

4. **TECHNICAL-INFO.md**
   - Infraestrutura atual
   - Tecnologias usadas
   - Métricas de código

### Recursos Azure

- Portal: https://portal.azure.com
- Docs: https://docs.microsoft.com/azure
- CLI Ref: https://docs.microsoft.com/cli/azure
- Pricing: https://azure.microsoft.com/pricing/calculator

### Comandos Úteis

```bash
# Listar recursos
az resource list --resource-group rg-jsmc-website-prod --output table

# Verificar custos
az consumption usage list --output table

# Logs Functions
az monitor log-analytics query \
  --workspace {workspace-id} \
  --analytics-query "traces | where timestamp > ago(1h)"

# Status Front Door
az afd profile show \
  --resource-group rg-jsmc-website-prod \
  --profile-name fd-jsmc-website-prod \
  --query "provisioningState"
```

---

## 🎯 Objetivos da Migração

✅ **Funcionalidade:** Preservar 100% das funcionalidades atuais  
✅ **Performance:** Manter ou melhorar (Lighthouse 90+)  
✅ **Custo:** Similar ou menor que AWS ($10-20/mês)  
✅ **CI/CD:** Deploy <30s preservado  
✅ **FinOps:** Controle total de custos e recursos  
✅ **Nova Seção:** Institucional implementada  
✅ **Downtime:** Mínimo possível (<5 min no DNS switch)  

---

## ⚠️ Pontos de Atenção

```
1. DNS Propagation: 24-48h
   → Configurar com antecedência

2. SSL Certificate: Automático mas pode demorar 2-4h
   → Validar domínio antes

3. Custos: Monitorar primeira semana
   → Budget alerts configurados

4. Rollback: AWS mantido 30 dias
   → Não desprovisionar antes

5. Testing: Completo antes do switch
   → UAT obrigatório
```

---

## 📊 Métricas de Sucesso

| Métrica | Target | Como Medir |
|---------|--------|------------|
| Lighthouse Score | 90+ | Chrome DevTools |
| Uptime | 99.9% | Azure Monitor |
| TTFB | <200ms | Chrome DevTools |
| Deploy Time | <30s | GitHub Actions |
| Monthly Cost | <$25 | Azure Cost Management |
| Email Delivery | 100% | Application Insights |

---

## 🚦 Status Atual

```
✅ Documentação: COMPLETA
✅ Plano de Migração: APROVADO
✅ Scripts CLI: PRONTOS
✅ GitHub Actions: PRONTO
✅ Design Institucional: PRONTO

⏳ Aguardando:
  - Aprovação para criar branch jsmc-azure
  - Aprovação para provisionar Azure
  - Conteúdo para seção Institucional (textos, PDFs, vídeos)
```

---

<div align="center">

**Guia criado em 10 de Dezembro de 2024**

**Versão 1.0.0**

[![Status](https://img.shields.io/badge/status-pronto%20para%20início-brightgreen.svg)](.)

**JSMC Soluções - Azure Migration**

🚀 **Próximo passo:** Criar branch `jsmc-azure` e provisionar infraestrutura

</div>

---

**© 2024 JSMC Soluções. Guia de Migração.**
