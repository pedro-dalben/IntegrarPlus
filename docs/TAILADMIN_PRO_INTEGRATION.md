# TailAdmin Pro Integration

## 📋 Visão Geral

Esta integração traz apenas os componentes essenciais do TailAdmin Pro para o projeto Rails, mantendo a performance e evitando importações desnecessárias.

## 🎯 Componentes Disponíveis

### 📅 FullCalendar
```html
<div data-calendar></div>
```

### 📊 ApexCharts
```html
<div data-chart="line" data-chart-data='{"series":[{"name":"Sales","data":[30,40,35,50,49,60,70,91,125]}],"xaxis":{"categories":["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep"]}}'></div>
```

### 🎠 Swiper (Carrossel)
```html
<div data-swiper class="swiper">
  <div class="swiper-wrapper">
    <div class="swiper-slide">Slide 1</div>
    <div class="swiper-slide">Slide 2</div>
  </div>
  <div class="swiper-pagination"></div>
  <div class="swiper-button-next"></div>
  <div class="swiper-button-prev"></div>
</div>
```

### 📁 Dropzone (Upload)
```html
<div data-dropzone data-url="/upload" data-accepted-files="image/*" data-max-files="5" data-max-filesize="2"></div>
```

### 🗺️ JSVectorMap
```html
<div id="map" style="height: 400px;"></div>
```

### 💻 Prism.js (Syntax Highlighting)
```html
<pre><code class="language-javascript">
function hello() {
  console.log("Hello World!");
}
</code></pre>
```

## 🎨 Classes CSS Disponíveis

### Botões
- `.ta-btn` - Botão base
- `.ta-btn-primary` - Botão primário
- `.ta-btn-secondary` - Botão secundário

### Inputs
- `.ta-input` - Input base

### Menu
- `.menu-item` - Item do menu
- `.menu-item-active` - Item ativo
- `.menu-item-inactive` - Item inativo
- `.menu-dropdown` - Dropdown do menu
- `.menu-dropdown-item` - Item do dropdown
- `.menu-dropdown-item-active` - Item ativo do dropdown
- `.menu-dropdown-item-inactive` - Item inativo do dropdown

### Utilitários
- `.no-scrollbar` - Remove scrollbar
- `.animate-fade-in` - Animação de fade in

## 🚀 Como Usar

### 1. Calendário
```erb
<%= content_tag :div, '', data: { calendar: true }, class: 'h-96' %>
```

### 2. Gráfico
```erb
<%= content_tag :div, '', 
    data: { 
      chart: 'line',
      chart_data: {
        series: [{ name: 'Vendas', data: [30,40,35,50,49,60,70,91,125] }],
        xaxis: { categories: ['Jan','Fev','Mar','Abr','Mai','Jun'] }
      }.to_json
    },
    class: 'h-64' %>
```

### 3. Carrossel
```erb
<div data-swiper class="swiper">
  <div class="swiper-wrapper">
    <% @images.each do |image| %>
      <div class="swiper-slide">
        <%= image_tag image.url, class: 'w-full h-64 object-cover' %>
      </div>
    <% end %>
  </div>
  <div class="swiper-pagination"></div>
  <div class="swiper-button-next"></div>
  <div class="swiper-button-prev"></div>
</div>
```

### 4. Upload
```erb
<%= content_tag :div, '', 
    data: { 
      dropzone: true,
      url: '/admin/upload',
      accepted_files: 'image/*',
      max_files: 5,
      max_filesize: 2
    },
    class: 'border-2 border-dashed border-gray-300 rounded-lg p-8 text-center' %>
```

## 📦 Dependências Instaladas

- `@fullcalendar/core` - Calendário base
- `@fullcalendar/daygrid` - Vista de calendário por dia/mês
- `@fullcalendar/timegrid` - Vista de calendário por hora
- `@fullcalendar/interaction` - Interações do calendário
- `@fullcalendar/list` - Vista de lista do calendário
- `apexcharts` - Gráficos
- `swiper` - Carrosséis
- `dropzone` - Upload de arquivos
- `prismjs` - Syntax highlighting
- `jsvectormap` - Mapas vetoriais

## 🔧 Configuração

Os componentes são inicializados automaticamente quando a página carrega. Eles procuram por elementos com os atributos `data-*` correspondentes.

## 📁 Estrutura de Arquivos

```
vendor/tailadmin-pro/
├── css/           # CSS do TailAdmin Pro
├── js/            # JavaScript do TailAdmin Pro
└── images/        # Imagens essenciais

app/frontend/
├── styles/tailadmin-pro.css      # CSS adaptado
├── javascript/tailadmin-pro.js   # JavaScript adaptado
└── entrypoints/application.js    # Entrypoint principal
```

## 🎯 Vantagens desta Abordagem

1. **Performance**: Apenas componentes necessários são carregados
2. **Manutenibilidade**: Código limpo e organizado
3. **Flexibilidade**: Fácil de adicionar/remover componentes
4. **Compatibilidade**: Funciona com Alpine.js e Stimulus existentes
5. **Tamanho**: Bundle menor, carregamento mais rápido
