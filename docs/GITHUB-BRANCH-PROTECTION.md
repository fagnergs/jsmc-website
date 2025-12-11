# GitHub Branch Protection Rules - main

## 🔒 Configuração de Proteção da Branch Main

### Objetivo
Proteger a branch `main` (produção) contra modificações acidentais e garantir qualidade do código através de revisões e testes automatizados.

---

## 📋 Passo a Passo para Configurar

### 1. Acessar Configurações do Repositório

1. Ir para: https://github.com/fagnergs/jsmc-website
2. Clicar em **Settings** (aba superior direita)
3. No menu lateral esquerdo, clicar em **Branches** (seção "Code and automation")

### 2. Adicionar Branch Protection Rule

1. Clicar no botão **Add rule** ou **Add branch protection rule**
2. No campo **Branch name pattern**, digitar: `main`

### 3. Configurar Proteções Recomendadas

#### ✅ Require a pull request before merging
- [x] **Require a pull request before merging**
  - Impede commits diretos na main
  - Força uso de Pull Requests

- [x] **Require approvals** (opcional, recomendado se houver equipe)
  - Número de aprovações necessárias: `1`
  - Garante revisão de código por outro desenvolvedor

#### ✅ Require status checks to pass before merging
- [x] **Require status checks to pass before merging**
  - Garante que testes/validações passem antes do merge

- [x] **Require branches to be up to date before merging**
  - Garante que a branch está atualizada com main antes do merge

**Status checks a adicionar:**
- Se usar GitHub Actions para testes, adicionar o nome do workflow
- Exemplo: `Deploy Lambda Function` (se quiser que passe antes do merge)

#### ✅ Require conversation resolution before merging (opcional)
- [x] **Require conversation resolution before merging**
  - Garante que todos os comentários do PR sejam resolvidos

#### ✅ Require signed commits (opcional, segurança extra)
- [ ] **Require signed commits**
  - Requer commits assinados com GPG (configuração adicional necessária)

#### ✅ Require linear history (opcional, histórico limpo)
- [ ] **Require linear history**
  - Impede merge commits, força rebase ou squash

#### 🚫 Do not allow bypassing the above settings
- [x] **Do not allow bypassing the above settings**
  - Nem administradores podem ignorar as regras

#### 🔒 Rules applied to everyone including administrators
- [x] **Include administrators**
  - Regras aplicam-se até para administradores

#### 🚫 Restrict who can push to matching branches
- [x] **Restrict who can push to matching branches** (opcional)
  - Adicionar usuários/times que podem fazer push direto
  - **Recomendação:** Deixar vazio para bloquear todos (forçar PRs)

#### ❌ Allow force pushes
- [ ] **Allow force pushes** (DESMARCAR)
  - **IMPORTANTE:** Manter DESMARCADO para prevenir sobrescritas

#### ❌ Allow deletions
- [ ] **Allow deletions** (DESMARCAR)
  - **IMPORTANTE:** Manter DESMARCADO para prevenir deleção da branch

---

## 🎯 Configuração Recomendada para JSMC Website

### Configuração Básica (Solo Developer)
```
✅ Require a pull request before merging
   ⚪ Require approvals: 0 (trabalho solo)
✅ Require status checks to pass before merging
   ✅ Require branches to be up to date
❌ Allow force pushes (DESMARCADO)
❌ Allow deletions (DESMARCADO)
✅ Include administrators
```

### Configuração Intermediária (Com revisão)
```
✅ Require a pull request before merging
   ✅ Require approvals: 1
✅ Require status checks to pass before merging
   ✅ Require branches to be up to date
✅ Require conversation resolution before merging
❌ Allow force pushes (DESMARCADO)
❌ Allow deletions (DESMARCADO)
✅ Include administrators
✅ Do not allow bypassing the above settings
```

### Configuração Avançada (Produção crítica)
```
✅ Require a pull request before merging
   ✅ Require approvals: 2
   ✅ Dismiss stale pull request approvals when new commits are pushed
✅ Require status checks to pass before merging
   ✅ Require branches to be up to date
   ✅ Status checks: Deploy Lambda Function, Tests
✅ Require conversation resolution before merging
✅ Require signed commits
✅ Require linear history
❌ Allow force pushes (DESMARCADO)
❌ Allow deletions (DESMARCADO)
✅ Include administrators
✅ Do not allow bypassing the above settings
✅ Restrict who can push to matching branches (lista específica)
```

---

## 🔄 Workflow após Configuração

### Fluxo de Trabalho Normal

1. **Desenvolvimento em branch separada**
   ```bash
   git checkout develop
   # Fazer alterações
   git add .
   git commit -m "feat: nova funcionalidade"
   git push origin develop
   ```

2. **Criar Pull Request no GitHub**
   - Ir para: https://github.com/fagnergs/jsmc-website/pulls
   - Clicar em **New Pull Request**
   - Base: `main` ← Compare: `develop`
   - Adicionar título e descrição
   - Clicar em **Create Pull Request**

3. **Revisão e Merge**
   - Aguardar status checks passarem (se configurado)
   - Revisar código (se aprovação configurada)
   - Clicar em **Merge Pull Request**

4. **Sincronizar branches após merge**
   ```bash
   git checkout main
   git pull origin main

   git checkout site-azure
   git merge main
   git push origin site-azure
   ```

### ⚠️ Emergência (Bypass temporário)

Se necessário fazer push direto em emergência:

1. Ir em Settings → Branches → Edit rule
2. Temporariamente desmarcar proteções
3. Fazer o push necessário
4. **IMPORTANTE:** Reativar proteções imediatamente após

---

## 🛡️ Proteções Implementadas

| Proteção | Status | Objetivo |
|----------|--------|----------|
| Branch `production-v11.0.0` | ✅ Criada | Backup imutável |
| Tag `v11.0.0` | ✅ Criada | Release oficial |
| Branch Protection Rules | ⏳ Configurar | Prevenir alterações diretas |
| Force Push Prevention | ⏳ Configurar | Prevenir sobrescritas |
| Deletion Prevention | ⏳ Configurar | Prevenir deleção da branch |

---

## 📚 Referências

- [GitHub Docs - Branch Protection Rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [Best Practices for Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/managing-a-branch-protection-rule)

---

## 📝 Checklist de Configuração

- [ ] Acessar Settings → Branches no GitHub
- [ ] Criar regra para branch `main`
- [ ] Configurar "Require a pull request before merging"
- [ ] Configurar "Require status checks to pass"
- [ ] DESMARCAR "Allow force pushes"
- [ ] DESMARCAR "Allow deletions"
- [ ] MARCAR "Include administrators"
- [ ] Salvar regras
- [ ] Testar criando um PR de `develop` → `main`
- [ ] Mover este arquivo para `docs/COMPLETED-GITHUB-PROTECTION.md` após configuração

---

**Criado em:** 11/12/2025
**Última atualização:** 11/12/2025
**Versão protegida:** v11.0.0 (commit c00c30b)
