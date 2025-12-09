# 📋 TODO - Após Aprovação SES Production Access

## ⏰ Status: AGUARDANDO APROVAÇÃO AWS
**Solicitado em:** 09/12/2024
**Prazo esperado:** 24-48 horas (até 11/12/2024)
**Email de notificação:** fagner.silva@jsmc.com.br

---

## 🎯 Ações Necessárias Após Aprovação

### 1. Verificar Aprovação

```bash
# Executar este comando para verificar status:
aws sesv2 get-account --region us-east-1 | grep ProductionAccessEnabled

# Se retornar "true", foi aprovado! ✅
```

### 2. Descomentar Reply-To na Lambda

**Arquivo:** `lambda/contact-form-handler.js`
**Linha:** ~201

**Alterar DE:**
```javascript
        }
        // ReplyToAddresses temporariamente comentado devido ao Sandbox SES
        // Será reativado após aprovação de Production Access
        // ReplyToAddresses: [data.email]
    };
```

**Alterar PARA:**
```javascript
        },
        ReplyToAddresses: [data.email]
    };
```

### 3. Fazer Deploy

```bash
cd /Users/fagnergs/Documents/GitHub/jsmc-website

git add lambda/contact-form-handler.js
git commit -m "feat: reativar Reply-To após aprovação SES Production Access

AWS SES saiu do Sandbox mode.
Reply-To agora funciona com qualquer email.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

git push origin develop
git push origin main
```

### 4. Testar Formulário

1. Acessar https://jsmc.com.br
2. Preencher formulário com qualquer email
3. Enviar
4. Verificar email chegou
5. Verificar que **Reply-To** funciona (responder email e ver que vai para o remetente original)

---

## 🔧 Melhorias Opcionais (Evitar SPAM)

### A. Configurar SPF no DNS

**Se ainda não tiver SPF:**
```
Tipo: TXT
Nome: @ ou jsmc.com.br
Valor: "v=spf1 include:spf.protection.outlook.com include:amazonses.com ~all"
```

**Se já tiver SPF do Office 365:**
- Apenas adicionar `include:amazonses.com` ao registro existente
- NÃO substituir o registro inteiro

### B. Configurar DKIM (Recomendado)

```bash
# 1. No Console AWS SES:
AWS Console > SES > Verified identities > jsmc.com.br

# 2. Aba "Authentication"

# 3. Se DKIM não estiver configurado:
- Clicar "Edit" na seção DKIM
- Easy DKIM: Enabled
- Copiar os 3 registros CNAME

# 4. Adicionar no DNS (Admin Microsoft 365):
Settings > Domains > jsmc.com.br > DNS records > Add record

Para cada um dos 3 registros:
Tipo: CNAME
Nome: xxxxx._domainkey
Aponta para: xxxxx.dkim.amazonses.com
TTL: 3600
```

### C. Adicionar à Whitelist do Office 365

```
1. Admin Center > Exchange > Mail flow > Rules
2. Create rule:
   - Name: "AWS SES - Não marcar como SPAM"
   - Apply this rule if: Sender address includes 'noreply@jsmc.com.br'
   - Do the following: Set spam confidence level (SCL) to -1
3. Save
```

---

## 📊 Monitoramento

### Verificar Métricas SES

```bash
# Ver estatísticas de envio
aws ses get-send-statistics --region us-east-1

# Ver reputação
aws sesv2 get-account --region us-east-1

# Ver logs recentes da Lambda
aws logs tail /aws/lambda/jsmc-contact-form-handler --since 1h --region us-east-1
```

### Verificar Bounce Rate

```bash
# Taxa de rejeição (deve ser < 5%)
aws cloudwatch get-metric-statistics \
  --namespace AWS/SES \
  --metric-name Reputation.BounceRate \
  --start-time $(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 86400 \
  --statistics Average \
  --region us-east-1
```

---

## ⚠️ Importante

- **NÃO deletar este arquivo** até completar todas as ações
- Após completar, mover para `docs/COMPLETED-SES-SETUP.md`
- Manter documentação para referência futura

---

**Criado em:** 09/12/2024 19:55 UTC-3
**Criado por:** Claude Code
