# 🌐 JSMC Soluções - Website Profissional

<div align="center">

[![Deploy Status](https://github.com/JSMC-Solucoes/website/actions/workflows/deploy.yml/badge.svg)](https://github.com/JSMC-Solucoes/website/actions)
[![Website Status](https://img.shields.io/website?url=https%3A%2F%2Fjsmc.com.br)](https://jsmc.com.br)
[![Lighthouse Score](https://img.shields.io/badge/Lighthouse-95+-4FC3F7)](https://jsmc.com.br)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Website moderno e otimizado para consultoria em energia**

[🌍 Acessar Website](https://jsmc.com.br) • [📖 Documentação](#documentação) • [🚀 Deploy](#deployment) • [💬 Contato](#contato)

</div>

---

## 📋 Sobre o Projeto

JSMC Soluções é uma empresa especializada em consultoria do setor energético, com atuação em:

- ⚡ **Geração e Distribuição de Energia**: Consultoria técnica completa
- 🤖 **IoT e Automação**: Projetos de grid modernization
- 📊 **Regulação**: Assessoria em assuntos regulatórios
- 🔧 **Operação e Manutenção**: Suporte especializado O&M

### 🎯 Serviços Principais

| Categoria | Serviços |
|-----------|----------|
| **Automação** | Grid Modernization (GM), ADMS, DERMS, DSO |
| **Inovação** | PDI, Projetos IoT, Desenvolvimento de Produtos |
| **Segurança** | Cybersegurança TI/TO, O&M, BESS |
| **Assessoria** | Regulatória, Due Diligence, Engenharia |

---

## 🏗️ Arquitetura Técnica

```
┌─────────────────────────────────────────┐
│         Domain: jsmc.com.br             │
│      (DNS Microsoft - Office 365)       │
└────────────────────┬────────────────────┘
                     │
            HTTPS via ACM + CloudFront
                     │
        ┌────────────┴────────────┐
        │                         │
    ┌───▼───┐            ┌────────▼──┐
    │CloudFront           │ S3 Bucket │
    │- Caching          │ - Versionado
    │- Compression    │ - Replicado
    │- OAC Access     │ - Encrypted
    └───────┘            └───────────┘
        │                     │
        └──────────┬──────────┘
                   │
        ┌──────────▼──────────┐
        │  GitHub Actions     │
        │  - CI/CD Automático │
        │  - Deploy <30seg    │
        │  - Tests & Quality  │
        └─────────────────────┘
```

### 🛠️ Stack Tecnológico

**Frontend:**
- HTML5 Semântico
- CSS3 com Grid & Flexbox
- JavaScript Vanilla (ES6+)
- Tailwind-inspired Custom CSS

**Build & Deployment:**
- AWS S3 (Static Hosting)
- AWS CloudFront (CDN + HTTPS)
- AWS ACM (SSL/TLS)
- GitHub Actions (CI/CD)

**Infrastructure as Code:**
- CloudFormation / SAM
- IAM Roles & Policies
- CloudWatch Monitoring

**Performance:**
- Lighthouse Score: 95+
- Time to First Byte: <100ms
- Fully Responsive Design

---

## 🚀 Deployment

### ⚡ Início Rápido

#### Pré-requisitos
```bash
# Verificar versões
node --version      # v18+
aws --version       # AWS CLI 2+
git --version       # git 2.0+
```

#### Setup Local
```bash
# Clone o repositório
git clone https://github.com/JSMC-Solucoes/website.git
cd website

# Instale dependências
npm install

# Teste local
npm start
# Acesse http://localhost:8080
```

#### Deploy para AWS

**1. Implantar Infraestrutura:**
```bash
# Defina certificado SSL/TLS no AWS ACM (já requer validação DNS)
export CERT_ARN="arn:aws:acm:us-east-1:xxxxx:certificate/xxxxx"

# Deploy CloudFormation
aws cloudformation create-stack \
  --stack-name jsmc-website-stack \
  --template-body file://aws-infrastructure.yaml \
  --parameters ParameterKey=CertificateArn,ParameterValue=$CERT_ARN \
  --capabilities CAPABILITY_IAM \
  --region us-east-1

# Aguarde conclusão (5-10 min)
aws cloudformation wait stack-create-complete \
  --stack-name jsmc-website-stack --region us-east-1
```

**2. Configurar GitHub Secrets:**
1. Vá para `Settings > Secrets and variables > Actions`
2. Adicione:
   - `AWS_ROLE_ARN`: ARN da role IAM criada
   - `AWS_S3_BUCKET`: Nome do bucket S3
   - `AWS_CLOUDFRONT_ID`: ID da distribuição CloudFront

**3. Deploy Automático:**
```bash
# Qualquer push para main dispara deploy automático
git add .
git commit -m "Atualização de conteúdo"
git push origin main

# GitHub Actions executará:
# ✅ Build & Validação
# ✅ Upload S3
# ✅ Invalidação CloudFront
# ✅ Notificação
# Total: <30 segundos
```

📖 **[Guia Completo de Deployment](./DEPLOYMENT.md)**

---

## 📁 Estrutura do Projeto

```
website/
├── index.html                 # Página principal
├── css/
│   └── styles.css            # Estilos (Paleta de cores do setor)
├── js/
│   └── main.js               # Interatividades
├── assets/                    # Imagens e recursos (opcional)
├── .github/
│   └── workflows/
│       └── deploy.yml        # CI/CD Pipeline
├── aws-infrastructure.yaml   # CloudFormation Stack
├── package.json              # Dependências npm
├── lighthouserc.json         # Configuração performance
├── DEPLOYMENT.md             # Guia de publicação
└── README.md                 # Este arquivo
```

---

## 🎨 Design & Paleta de Cores

### Cores Principais (Setor de Energia)
```
🔵 Azul Energético:    #00A3D9 (Primary)
🟠 Laranja Destaque:   #FF8C42 (Secondary)
⬛ Cinza Profissional:  #2C3E50 (Dark)
⚪ Branco Limpo:       #FFFFFF (Background)
```

### Responsividade
- ✅ Desktop (1200px+)
- ✅ Tablet (768px - 1199px)
- ✅ Mobile (< 768px)
- ✅ Muito pequeno (< 480px)

---

## ✨ Funcionalidades

### 🎯 Seções Principais
- **Hero** - Impacto visual com chamada principal
- **Sobre** - Quem Somos, Missão, Visão
- **Serviços** - Categorização clara e intuitiva
- **Diferenciais** - 8 pontos-chave da empresa
- **Clientes** - Logos de empresas parceiras
- **Contato** - Formulário + Informações diretas
- **Footer** - Links e redes sociais

### 🔧 Funcionalidades Técnicas
- ✅ Menu Mobile responsivo
- ✅ Scroll suave entre seções
- ✅ Formulário de contato com validação
- ✅ Animações ao entrar em viewport
- ✅ Lazy loading de imagens
- ✅ Ripple effect em botões
- ✅ Performance otimizada

---

## 📊 Performance

### Lighthouse Scores (Objetivo)
```
┌──────────────────────────────┐
│ Performance:     95+ ✅       │
│ Accessibility:   95+ ✅       │
│ Best Practices:  95+ ✅       │
│ SEO:            100+ ✅       │
└──────────────────────────────┘
```

### Tempo de Carregamento
- **Primeiro carregamento**: ~2s
- **Recarregamento com cache**: ~500ms
- **Invalidação CloudFront**: <30s

### Otimizações
- Minificação de CSS/JS
- Compressão gzip (automática CloudFront)
- HTTP/2 + HTTP/3
- Cache-Control headers otimizado
- Imagens otimizadas

---

## 🔒 Segurança

### HTTPS Automático
```
✅ Certificado SSL/TLS via AWS ACM
✅ Redirecionamento HTTP → HTTPS
✅ TLS 1.2+
✅ HSTS habilitado
```

### Cloud Security
```
✅ S3 Block Public Access
✅ CloudFront Origin Access Control (OAC)
✅ IAM Roles com privilégio mínimo
✅ Bucket versioning habilitado
✅ CloudWatch monitoring
```

### CI/CD Security
```
✅ OIDC (sem credenciais estáticas)
✅ GitHub Secrets protegidos
✅ Audit logs automáticos
```

---

## 🧪 Desenvolvimento

### Scripts Disponíveis

```bash
# Servidor local
npm start          # Porta 8080

# Build
npm run build      # Prepara arquivos

# Qualidade
npm run lint       # Valida HTML
npm run audit      # Verifica vulnerabilidades

# Performance
npm run lighthouse # Teste Lighthouse

# Deploy
npm run deploy-local # Deploy manual S3
```

### Ambiente de Desenvolvimento

```bash
# Instale dependências adicionais (opcional)
npm install --save-dev lighthouse @lighthouse-ci/cli

# Modo watch (para IDE)
# Usar extensão Live Server do VSCode

# Teste com Device Emulation
# Abra DevTools (F12) > Device Toolbar
```

---

## 📚 Documentação

### Arquivos Importantes
- [DEPLOYMENT.md](./DEPLOYMENT.md) - Guia passo-a-passo de publicação
- [AWS CloudFormation](./aws-infrastructure.yaml) - Infraestrutura IaC
- [GitHub Actions](../.github/workflows/deploy.yml) - Pipeline CI/CD

### Referências Externas
- [AWS S3 Docs](https://docs.aws.amazon.com/s3/)
- [CloudFront Best Practices](https://docs.aws.amazon.com/cloudfront/latest/developerguide/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

---

## 🤝 Contribuindo

### Fluxo de Trabalho
1. **Fork** o repositório
2. **Branch** feature (`git checkout -b feature/AmazingFeature`)
3. **Commit** mudanças (`git commit -m 'Add AmazingFeature'`)
4. **Push** branch (`git push origin feature/AmazingFeature`)
5. **Pull Request** no GitHub

### Padrões de Código
- HTML semântico
- CSS com BEM naming
- JavaScript ES6+
- Responsivo first-mobile

---

## 🐛 Troubleshooting

### Problema: Deploy falha no GitHub Actions
**Solução:** Verifique AWS_ROLE_ARN nos secrets

### Problema: Certificado SSL inválido
**Solução:** Valide domínio no AWS ACM Console

### Problema: Alterações não aparecem
**Solução:** Limpe cache CloudFront (é automático via Actions)

📞 Mais em [DEPLOYMENT.md](./DEPLOYMENT.md)

---

## 📞 Contato & Suporte

### JSMC Soluções
- 🌐 **Website**: https://jsmc.com.br
- 📧 **Email**: informacoes@jsmc.com.br
- 📱 **Telefone**: +55 11 92002-9999
- 📍 **Localização**: Rio Claro - SP, Brasil

### Executivos
- **João de Souza** (Diretor)
  - ☎️ (11) 99194-0590
  - 📧 joao.souza@jsmc.com.br

- **Fagner Silva** (Tecnologia & Projetos)
  - ☎️ (21) 99254-456
  - 📧 fagner.silva@jsmc.com.br

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja [LICENSE](LICENSE) para detalhes.

---

## 🙏 Agradecimentos

- AWS por infraestrutura confiável
- GitHub por CI/CD poderoso
- Comunidade open-source

---

<div align="center">

**Desenvolvido com ❤️ para JSMC Soluções**

⭐ Se este projeto foi útil, dê uma star!

[☝️ Voltar ao topo](#jsmc-soluções---website-profissional)

</div>

---

**Última atualização**: Dezembro 2024  
**Versão**: 1.0.0  
**Status**: Production Ready ✅
