# 🏢 SEÇÃO INSTITUCIONAL - Especificação e Design

<div align="center">

**Nova Seção: Institucional - JSMC Soluções**

[![Design](https://img.shields.io/badge/design-especificação-blue.svg)](.)

</div>

---

## 📋 Visão Geral

A nova seção "Institucional" será adicionada ao website JSMC para fornecer informações corporativas, materiais para download e conteúdo em vídeo para clientes e parceiros.

---

## 🎯 Objetivos

```
✅ Apresentar informações corporativas da JSMC
✅ Disponibilizar materiais para download (PDFs)
✅ Exibir vídeos institucionais e técnicos
✅ Manter consistência visual com o site atual
✅ Design responsivo (mobile-first)
✅ Performance otimizada (Lighthouse 90+)
```

---

## 📐 Estrutura da Seção

### Layout Proposto

```
┌─────────────────────────────────────────────────────────┐
│              SEÇÃO INSTITUCIONAL                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [TÍTULO: Institucional]                                │
│  Subtítulo: Conheça mais sobre a JSMC Soluções         │
│                                                         │
│  ┌───────────────────────────────────────────────┐     │
│  │                                               │     │
│  │  SOBRE A EMPRESA                              │     │
│  │  ────────────────                             │     │
│  │  Texto descritivo (3-4 parágrafos)           │     │
│  │  - Histórico                                  │     │
│  │  - Missão e Visão                             │     │
│  │  - Valores                                    │     │
│  │  - Certificações                              │     │
│  │                                               │     │
│  └───────────────────────────────────────────────┘     │
│                                                         │
│  ┌───────────────────────────────────────────────┐     │
│  │                                               │     │
│  │  MATERIAIS PARA DOWNLOAD                      │     │
│  │  ────────────────────────                     │     │
│  │                                               │     │
│  │  Grid de Cards (2-3 colunas):                │     │
│  │                                               │     │
│  │  📄 [Card 1]        📄 [Card 2]      📄 [3]   │     │
│  │  Apresentação       Catálogo         White    │     │
│  │  Institucional      Serviços         Paper    │     │
│  │  [Download PDF]     [Download]       [Down]   │     │
│  │                                               │     │
│  └───────────────────────────────────────────────┘     │
│                                                         │
│  ┌───────────────────────────────────────────────┐     │
│  │                                               │     │
│  │  VÍDEOS INSTITUCIONAIS                        │     │
│  │  ──────────────────────                       │     │
│  │                                               │     │
│  │  Grid de Vídeos (2 colunas):                 │     │
│  │                                               │     │
│  │  🎬 [Video 1]       🎬 [Video 2]              │     │
│  │  Apresentação       Projetos                  │     │
│  │  JSMC              Realizados                 │     │
│  │  [Play embed]      [Play embed]              │     │
│  │                                               │     │
│  │  🎬 [Video 3]       🎬 [Video 4]              │     │
│  │  Depoimentos       Tour Virtual               │     │
│  │  Clientes          Instalações                │     │
│  │  [Play embed]      [Play embed]              │     │
│  │                                               │     │
│  └───────────────────────────────────────────────┘     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🎨 Design System

### Cores

```css
/* Usar paleta existente do site */
--primary-blue: #00A3D9;      /* Azul energético */
--secondary-orange: #FF8C42;   /* Laranja destaque */
--dark-gray: #2C3E50;          /* Texto principal */
--white: #FFFFFF;              /* Fundo */
--light-gray: #F8F9FA;         /* Fundo alternativo */
```

### Tipografia

```css
/* Manter Poppins */
--font-family: 'Poppins', sans-serif;

/* Tamanhos */
--heading-size: 2.5rem;        /* Título seção */
--subheading-size: 1.5rem;     /* Subtítulos */
--body-size: 1rem;             /* Texto corpo */
--small-size: 0.875rem;        /* Textos pequenos */
```

### Espaçamento

```css
--section-padding: 80px 20px;
--card-spacing: 2rem;
--content-max-width: 1200px;
```

---

## 📝 HTML Estrutura

```html
<!-- Seção Institucional -->
<section id="institucional" class="institucional">
    <div class="container">
        <!-- Cabeçalho -->
        <div class="section-header">
            <h2>Institucional</h2>
            <p class="section-subtitle">Conheça mais sobre a JSMC Soluções</p>
        </div>

        <!-- Sobre a Empresa -->
        <div class="institucional-about">
            <h3>Sobre a JSMC Soluções</h3>
            <div class="about-content">
                <p>
                    A JSMC Soluções é uma empresa brasileira especializada em consultoria
                    para o setor de energia, com foco em Grid Modernization, IoT, automação
                    e regulação.
                </p>
                <p>
                    Com mais de [X] anos de experiência, atendemos os principais players
                    do mercado de utilities no Brasil, oferecendo soluções inovadoras e
                    expertise técnica de alto nível.
                </p>
                <p>
                    <strong>Missão:</strong> Transformar o setor energético através de
                    soluções tecnológicas e consultoria especializada.
                </p>
                <p>
                    <strong>Visão:</strong> Ser referência em consultoria e inovação para
                    o setor de energia no Brasil.
                </p>
            </div>
        </div>

        <!-- Materiais para Download -->
        <div class="institucional-downloads">
            <h3>Materiais para Download</h3>
            <div class="download-grid">
                <!-- Card 1 -->
                <div class="download-card">
                    <div class="download-icon">
                        <svg><!-- Ícone PDF --></svg>
                    </div>
                    <h4>Apresentação Institucional</h4>
                    <p>Conheça a JSMC Soluções, nossa história e nossos serviços.</p>
                    <a href="/assets/downloads/jsmc-apresentacao.pdf" 
                       class="btn btn-download" 
                       download>
                        <span>Download PDF</span>
                        <span class="file-size">(2.5 MB)</span>
                    </a>
                </div>

                <!-- Card 2 -->
                <div class="download-card">
                    <div class="download-icon">
                        <svg><!-- Ícone PDF --></svg>
                    </div>
                    <h4>Catálogo de Serviços</h4>
                    <p>Portfólio completo de soluções e serviços oferecidos.</p>
                    <a href="/assets/downloads/jsmc-catalogo-servicos.pdf" 
                       class="btn btn-download" 
                       download>
                        <span>Download PDF</span>
                        <span class="file-size">(3.1 MB)</span>
                    </a>
                </div>

                <!-- Card 3 -->
                <div class="download-card">
                    <div class="download-icon">
                        <svg><!-- Ícone PDF --></svg>
                    </div>
                    <h4>White Paper - Grid Modernization</h4>
                    <p>Estudo sobre modernização de redes elétricas no Brasil.</p>
                    <a href="/assets/downloads/jsmc-whitepaper-grid.pdf" 
                       class="btn btn-download" 
                       download>
                        <span>Download PDF</span>
                        <span class="file-size">(1.8 MB)</span>
                    </a>
                </div>
            </div>
        </div>

        <!-- Vídeos Institucionais -->
        <div class="institucional-videos">
            <h3>Vídeos Institucionais</h3>
            <div class="videos-grid">
                <!-- Vídeo 1 -->
                <div class="video-card">
                    <div class="video-wrapper">
                        <!-- YouTube embed -->
                        <iframe 
                            src="https://www.youtube.com/embed/VIDEO_ID_1" 
                            title="Apresentação JSMC Soluções"
                            frameborder="0" 
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                            allowfullscreen>
                        </iframe>
                    </div>
                    <h4>Apresentação JSMC Soluções</h4>
                    <p>Conheça a JSMC e nossos principais diferenciais.</p>
                </div>

                <!-- Vídeo 2 -->
                <div class="video-card">
                    <div class="video-wrapper">
                        <iframe 
                            src="https://www.youtube.com/embed/VIDEO_ID_2" 
                            title="Projetos Realizados"
                            frameborder="0" 
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                            allowfullscreen>
                        </iframe>
                    </div>
                    <h4>Projetos Realizados</h4>
                    <p>Cases de sucesso e projetos implementados.</p>
                </div>

                <!-- Vídeo 3 -->
                <div class="video-card">
                    <div class="video-wrapper">
                        <iframe 
                            src="https://www.youtube.com/embed/VIDEO_ID_3" 
                            title="Depoimentos de Clientes"
                            frameborder="0" 
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                            allowfullscreen>
                        </iframe>
                    </div>
                    <h4>Depoimentos de Clientes</h4>
                    <p>O que nossos clientes falam sobre a JSMC.</p>
                </div>

                <!-- Vídeo 4 -->
                <div class="video-card">
                    <div class="video-wrapper">
                        <iframe 
                            src="https://www.youtube.com/embed/VIDEO_ID_4" 
                            title="Tour Virtual - Instalações"
                            frameborder="0" 
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                            allowfullscreen>
                        </iframe>
                    </div>
                    <h4>Tour Virtual - Instalações</h4>
                    <p>Conheça nossa estrutura e equipe.</p>
                </div>
            </div>
        </div>
    </div>
</section>
```

---

## 🎨 CSS Styles

```css
/* ==================== SEÇÃO INSTITUCIONAL ==================== */

.institucional {
    padding: 80px 20px;
    background: linear-gradient(135deg, #f8f9fa 0%, #ffffff 100%);
}

.institucional .container {
    max-width: 1200px;
    margin: 0 auto;
}

.institucional .section-header {
    text-align: center;
    margin-bottom: 60px;
}

.institucional h2 {
    font-size: 2.5rem;
    color: var(--dark-gray);
    margin-bottom: 15px;
}

.institucional .section-subtitle {
    font-size: 1.125rem;
    color: #666;
}

/* --- Sobre a Empresa --- */

.institucional-about {
    margin-bottom: 80px;
}

.institucional-about h3 {
    font-size: 2rem;
    color: var(--primary-blue);
    margin-bottom: 30px;
    position: relative;
    padding-bottom: 15px;
}

.institucional-about h3::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 0;
    width: 60px;
    height: 3px;
    background: var(--secondary-orange);
}

.institucional-about .about-content {
    max-width: 900px;
    margin: 0 auto;
}

.institucional-about p {
    font-size: 1.125rem;
    line-height: 1.8;
    color: #555;
    margin-bottom: 20px;
}

.institucional-about strong {
    color: var(--dark-gray);
    font-weight: 600;
}

/* --- Downloads --- */

.institucional-downloads {
    margin-bottom: 80px;
}

.institucional-downloads h3 {
    font-size: 2rem;
    color: var(--primary-blue);
    margin-bottom: 40px;
    text-align: center;
}

.download-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 30px;
    max-width: 1000px;
    margin: 0 auto;
}

.download-card {
    background: white;
    border-radius: 12px;
    padding: 30px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
    text-align: center;
}

.download-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
}

.download-icon {
    width: 60px;
    height: 60px;
    margin: 0 auto 20px;
    background: linear-gradient(135deg, var(--primary-blue), var(--secondary-orange));
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
}

.download-icon svg {
    width: 30px;
    height: 30px;
    fill: white;
}

.download-card h4 {
    font-size: 1.25rem;
    color: var(--dark-gray);
    margin-bottom: 15px;
}

.download-card p {
    color: #666;
    margin-bottom: 20px;
    line-height: 1.6;
}

.btn-download {
    display: inline-block;
    padding: 12px 30px;
    background: var(--primary-blue);
    color: white;
    text-decoration: none;
    border-radius: 6px;
    font-weight: 500;
    transition: background 0.3s ease;
}

.btn-download:hover {
    background: var(--secondary-orange);
}

.file-size {
    display: block;
    font-size: 0.875rem;
    opacity: 0.8;
    margin-top: 5px;
}

/* --- Vídeos --- */

.institucional-videos {
    margin-bottom: 40px;
}

.institucional-videos h3 {
    font-size: 2rem;
    color: var(--primary-blue);
    margin-bottom: 40px;
    text-align: center;
}

.videos-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
    gap: 30px;
    max-width: 1100px;
    margin: 0 auto;
}

.video-card {
    background: white;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.video-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
}

.video-wrapper {
    position: relative;
    padding-bottom: 56.25%; /* 16:9 Aspect Ratio */
    height: 0;
    overflow: hidden;
}

.video-wrapper iframe {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
}

.video-card h4 {
    font-size: 1.25rem;
    color: var(--dark-gray);
    padding: 20px 20px 10px;
}

.video-card p {
    color: #666;
    padding: 0 20px 20px;
    line-height: 1.6;
}

/* --- Responsivo --- */

@media (max-width: 768px) {
    .institucional {
        padding: 60px 15px;
    }

    .institucional h2 {
        font-size: 2rem;
    }

    .institucional-about h3,
    .institucional-downloads h3,
    .institucional-videos h3 {
        font-size: 1.5rem;
    }

    .download-grid,
    .videos-grid {
        grid-template-columns: 1fr;
        gap: 20px;
    }

    .videos-grid {
        grid-template-columns: 1fr;
    }
}

@media (max-width: 480px) {
    .institucional h2 {
        font-size: 1.75rem;
    }

    .download-card,
    .video-card {
        padding: 20px;
    }
}
```

---

## 📦 Armazenamento de Arquivos (Azure)

### Estrutura no Blob Storage

```
$web/
├── assets/
│   └── downloads/
│       ├── jsmc-apresentacao.pdf          (2-3 MB)
│       ├── jsmc-catalogo-servicos.pdf     (2-3 MB)
│       ├── jsmc-whitepaper-grid.pdf       (1-2 MB)
│       ├── jsmc-casos-sucesso.pdf         (opcional)
│       └── jsmc-certificacoes.pdf         (opcional)
```

### Upload via Azure CLI

```bash
# Upload PDFs para Blob Storage
az storage blob upload-batch \
  --account-name jsmcwebsiteprod \
  --destination '$web/assets/downloads' \
  --source ./downloads \
  --pattern "*.pdf" \
  --content-type "application/pdf" \
  --overwrite
```

---

## 🎬 Vídeos - Opções de Hospedagem

### Opção 1: YouTube (Recomendado)

**Vantagens:**
- Gratuito
- CDN global
- Player responsivo
- Analytics integrado

**Embed Code:**
```html
<iframe 
    width="560" 
    height="315" 
    src="https://www.youtube.com/embed/VIDEO_ID" 
    title="Título do Vídeo"
    frameborder="0" 
    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
    allowfullscreen>
</iframe>
```

### Opção 2: Vimeo

**Vantagens:**
- Qualidade superior
- Sem anúncios
- Customização avançada

**Embed Code:**
```html
<iframe 
    src="https://player.vimeo.com/video/VIDEO_ID" 
    width="640" 
    height="360" 
    frameborder="0" 
    allow="autoplay; fullscreen; picture-in-picture" 
    allowfullscreen>
</iframe>
```

### Opção 3: Azure Media Services

**Vantagens:**
- Controle total
- Integração nativa Azure
- Streaming adaptativo

**Desvantagens:**
- Custo adicional (~$10-50/mês)
- Complexidade maior

---

## ✅ Checklist de Implementação

```
[ ] Criar HTML da seção
[ ] Implementar CSS responsivo
[ ] Preparar PDFs (otimizados)
[ ] Upload PDFs para Azure Blob Storage
[ ] Criar canal YouTube (se necessário)
[ ] Upload vídeos para YouTube/Vimeo
[ ] Obter IDs dos vídeos
[ ] Configurar embeds
[ ] Adicionar link no menu principal
[ ] Testar responsividade (mobile/tablet/desktop)
[ ] Validar acessibilidade (WCAG 2.1)
[ ] Otimizar performance (Lighthouse)
[ ] Testar downloads
[ ] Testar playback vídeos
[ ] Deploy para jsmc-azure branch
[ ] Validação final
```

---

## 📊 Performance Targets

```yaml
Lighthouse Scores:
  - Performance: >= 90
  - Accessibility: >= 95
  - Best Practices: >= 95
  - SEO: >= 95

Tamanho Máximo:
  - PDFs: 3 MB cada
  - Vídeos: YouTube (sem limite)
  - HTML/CSS: +5 KB

Carregamento:
  - Seção acima da dobra: < 2s
  - PDFs (on-demand): Não impacta
  - Vídeos (lazy load): Não impacta
```

---

## 📞 Conteúdo Necessário

Para implementar a seção, necessitamos:

```
1. Textos:
   [ ] Sobre a empresa (3-4 parágrafos)
   [ ] Descrição de cada PDF
   [ ] Descrição de cada vídeo

2. PDFs:
   [ ] Apresentação institucional
   [ ] Catálogo de serviços
   [ ] White papers / estudos
   [ ] Certificações (opcional)

3. Vídeos:
   [ ] Apresentação JSMC (2-3 min)
   [ ] Projetos / Cases (3-5 min)
   [ ] Depoimentos clientes (2-3 min)
   [ ] Tour virtual (opcional, 2-3 min)

4. Assets:
   [ ] Ícone PDF (SVG)
   [ ] Ícone vídeo (SVG)
```

---

<div align="center">

**Documento criado em 10 de Dezembro de 2024**

**Versão 1.0.0**

[![Design](https://img.shields.io/badge/design-ready-brightgreen.svg)](.)

**Preparado para JSMC Soluções**

</div>

---

**© 2024 JSMC Soluções. Documento de Design.**
