# 📸 Guia de Imagens - JSMC Soluções Website

## Recomendações de Imagens por Seção

### 🎯 Hero Section
**Tema**: Energia, Tecnologia, Modernidade

Recomendações:
- Torres de transmissão de energia (background desfocado)
- Painéis solares em perspectiva
- Linhas de energia com iluminação moderna
- Cidade à noite com redes elétricas
- Estação de transformação com efeito de energia

**Especificações**:
- Resolução: 1920x1080 (mínimo)
- Formato: WebP ou JPEG otimizado
- Peso: <200KB (comprimido)
- Proporção: 16:9
- Filtro: Aplicar overlay escuro (opacity 0.3) para melhor leitura

**Bancos de Imagens**:
- [Unsplash](https://unsplash.com/s/photos/power-grid)
- [Pexels](https://www.pexels.com/search/electricity/)
- [Pixabay](https://pixabay.com/images/search/energy/)

---

### 👥 Perfil da Empresa (About)
**Tema**: Profissionalismo, Expertise, Trabalho em Equipe

Recomendações por subsção:
1. **Equipe técnica**: Profissionais em ambiente de trabalho moderno
2. **Software/Hardware**: Telas com dashboards, equipamentos de monitoramento
3. **Campo**: Técnicos trabalhando em infraestrutura

**Especificações**:
- Resolução: 800x600 mínimo
- Formato: JPEG com qualidade 85%
- Proporção: 4:3 ou 1:1 (dependendo do layout)
- Peso: <150KB cada

---

### 🔧 Serviços (Services)
**Tema**: Cada serviço com ícone + imagem exemplar

#### Automação & Utilities
- SCADA/HMI dashboard colorido
- Sala de controle com monitores
- Painéis de distribuição
- Sistemas supervisórios

#### PDI & Inovação
- Laboratório de prototipagem
- Computadores/tablets com analytics
- IoT sensors em campo
- Startup/innovation workspace

#### Operação & Segurança
- Data center com racks
- Equipe em videoconferência
- Cybersecurity dashboard
- Equipamentos de segurança

**Especificações**:
- Resolução: 600x400 mínimo
- Formato: WebP otimizado
- Peso: <100KB
- Proporção: 3:2

---

### 🏆 Diferenciais
**Tema**: Números, gráficos, sucesso

Elementos visuais:
- Gráficos de crescimento
- Setas ascendentes
- Checkmarks
- Ilustrações abstratas
- Ícones customizados (SVG)

**Formato recomendado**: SVG inline (ícones) + JPEG (gráficos)

---

### 👥 Clientes
**Tema**: Logos de clientes

**Recomendações**:
- Logos em alta resolução (2x tamanho de exibição)
- Fundo branco/transparente
- Proporções consistentes
- Versões coloridas principais

**Para placeholder** (até ter logos reais):
```css
/* Usar cores de brand de cada cliente */
background: linear-gradient(135deg, #00A3D9, #FF8C42);
```

---

## 🎨 Paleta de Cores para Imagens

### Cores Primárias (Match Website)
- **Azul Energético**: #00A3D9
- **Laranja Destaque**: #FF8C42
- **Cinza Profissional**: #2C3E50

### Tons Recomendados para Imagens
- **Azuis escuros**: Estabilidade, confiança
- **Alaranjados quentes**: Energia, dinamismo
- **Cinzas neutros**: Profissionalismo
- **Branco**: Limpeza, clareza

---

## 📁 Estrutura de Pastas para Imagens

```
assets/
├── images/
│   ├── hero/
│   │   ├── background-transmission-tower.jpg
│   │   ├── background-solar-panels.jpg
│   │   └── overlay-pattern.svg
│   ├── about/
│   │   ├── team-working.jpg
│   │   ├── control-room.jpg
│   │   └── field-engineers.jpg
│   ├── services/
│   │   ├── automation-dashboard.jpg
│   │   ├── iot-sensors.jpg
│   │   ├── cybersecurity-center.jpg
│   │   └── maintenance-crew.jpg
│   ├── clients/
│   │   ├── waxsol-logo.png
│   │   ├── enel-logo.png
│   │   └── ...
│   └── icons/
│       ├── grid-modernization.svg
│       ├── iot-network.svg
│       ├── safety-shield.svg
│       └── innovation-lightbulb.svg
└── logo/
    ├── jsmc-color.svg
    ├── jsmc-white.svg
    ├── jsmc-icon.svg
    └── favicon.ico
```

---

## ✅ Otimização de Imagens

### Ferramentas Recomendadas
1. **TinyPNG/TinyJPG**: Compressão com qualidade
   - https://tinypng.com/

2. **ImageOptim**: Otimização local
   - https://imageoptim.com/

3. **ImageMagick**: Batch processing
   ```bash
   convert image.jpg -quality 85 -strip image-optimized.jpg
   ```

4. **CloudFront + CloudFlare**: Compressão automática
   - Já implementado na infraestrutura!

### Tamanhos Recomendados Finais
```
Hero Background: 100-150KB
About Images: 50-80KB
Service Cards: 40-60KB
Client Logos: 10-30KB (variável)
Icons: 5-15KB (SVG)
```

---

## 🖼️ Exemplos de Imagens por Estilo

### ✨ Moderno & Corporativo
- Fotografia profissional de estúdio
- Lighting natural ou LED professional
- Composição limpa e minimalista
- Alto contraste

### 🏭 Industrial & Técnico
- Fotografias reais de campo
- Equipamentos em funcionamento
- Ambientes de operação
- Contexto real do trabalho

### 🚀 Inovação & Tecnologia
- Dashboards e interfaces
- Prototipagem e labs
- Computadores e IoT
- Futuro/tendências

---

## 📷 Recomendações Específicas por Serviço

### Grid Modernization
**Imagens ideais**:
- Torres de transmissão modernas
- Smart meters
- Centros de controle
- Linhas de distribuição

**Estilo**: Industrial, técnico

### ADMS (Advanced Distribution Management Systems)
**Imagens ideais**:
- Dashboards coloridos
- Mapas de rede elétrica
- Salas de operação
- Gráficos em tempo real

**Estilo**: Tecnologia, dados

### IoT Projects
**Imagens ideais**:
- Sensores inteligentes
- Wireless networks
- Cloud computing illustration
- Data analytics visualization

**Estilo**: Moderno, tech

### Cybersecurity
**Imagens ideais**:
- Escudos/proteção
- Locks digitais
- Data centers seguros
- Certificações de segurança

**Estilo**: Seguro, profissional

### O&M (Operation & Maintenance)
**Imagens ideais**:
- Técnicos em campo
- Equipamento de teste
- Videoconferência remota
- Manutenção preventiva

**Estilo**: Prático, colaborativo

---

## 🎬 Implementação de Imagens no HTML

### Exemplo com Lazy Loading
```html
<!-- Hero with lazy loading -->
<header id="home" class="hero">
  <img 
    data-src="assets/images/hero/transmission-tower.jpg"
    alt="Torres de transmissão de energia - JSMC Soluções"
    class="hero-background"
    loading="lazy"
  />
</header>
```

### Exemplo com Responsive Images
```html
<img 
  src="assets/images/services/automation-dashboard.jpg"
  srcset="
    assets/images/services/automation-dashboard-small.jpg 480w,
    assets/images/services/automation-dashboard-medium.jpg 800w,
    assets/images/services/automation-dashboard-large.jpg 1200w
  "
  alt="Dashboard de automação ADMS"
  class="service-image"
/>
```

### Exemplo com WebP Fallback
```html
<picture>
  <source 
    srcset="assets/images/about/team-working.webp"
    type="image/webp"
  />
  <source 
    srcset="assets/images/about/team-working.jpg"
    type="image/jpeg"
  />
  <img 
    src="assets/images/about/team-working.jpg"
    alt="Equipe JSMC trabalhando"
  />
</picture>
```

---

## 📊 Performance Impact

### Impacto no LightHouse
- ✅ Imagens otimizadas: +5% performance
- ✅ Lazy loading: +10% performance
- ✅ Responsive images: +3% performance
- ✅ WebP format: +8% performance

**Meta**: LightHouse Performance > 90

---

## 🎯 Próximos Passos

1. **Selecionar imagens** baseado nas recomendações acima
2. **Otimizar** usando as ferramentas recomendadas
3. **Organizar** conforme estrutura de pastas
4. **Testar** lazy loading em navegadores
5. **Monitorar** performance com Lighthouse

---

## 📞 Fontes de Imagens de Qualidade

### Gratuitas (Free)
- [Unsplash](https://unsplash.com/) - Excelente qualidade
- [Pexels](https://www.pexels.com/) - Várias categorias
- [Pixabay](https://pixabay.com/) - Sem restrições
- [Freepik](https://www.freepik.com/) - Ilustrações

### Premium (Pagos)
- [Getty Images](https://www.gettyimages.com/)
- [Shutterstock](https://www.shutterstock.com/)
- [Adobe Stock](https://stock.adobe.com/)
- [iStock](https://www.istockphoto.com/)

### Customizadas (Recomendado)
- Fotografia profissional local
- Imagens reais de projetos JSMC
- Equipamentos e ambientes reais

---

**Última atualização**: Dezembro 2024
**Versão**: 1.0.0
