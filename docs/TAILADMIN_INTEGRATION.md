# Integração TailAdmin Pro

## Visão Geral

O TailAdmin Pro foi integrado ao projeto usando Vite e Rails, com todos os componentes JavaScript funcionando corretamente.

## Estrutura de Arquivos

### JavaScript Principal
- `app/frontend/entrypoints/application.js` - Entrypoint principal do Vite
- `app/frontend/javascript/tailadmin-pro.js` - Integração completa do TailAdmin Pro

### CSS
- `app/frontend/styles/application.css` - Estilos principais
- `vendor/tailadmin-pro/css/` - CSS do TailAdmin Pro

### Componentes
- `vendor/tailadmin-pro/js/components/` - Todos os componentes JavaScript
- `vendor/tailadmin-pro/partials/` - Templates HTML dos componentes

## Como Usar

### 1. Importação Automática

O TailAdmin Pro é carregado automaticamente através do `application.js`:

```javascript
import "../javascript/tailadmin-pro";
```

### 2. Componentes Disponíveis

#### Charts (Gráficos)
Todos os 24 charts estão disponíveis e são inicializados automaticamente:

```html
<!-- Exemplo de uso de chart -->
<div id="chart-01" class="w-full h-80"></div>
```

#### Datepickers
Dois tipos de datepicker configurados:

```html
<!-- Datepicker com range -->
<input type="text" class="datepicker" placeholder="Selecione datas">

<!-- Datepicker simples -->
<input type="text" class="datepickerTwo" placeholder="Selecione data">
```

#### Dropzone (Upload de Arquivos)
```html
<form action="/file/post" class="dropzone" id="demo-upload">
  <div class="dz-message" data-dz-message>
    <span>Arraste arquivos aqui ou clique para fazer upload</span>
  </div>
</form>
```

#### OTP (One-Time Password)
```html
<div id="otp-container">
  <input type="text" class="otp-input" maxlength="1">
  <input type="text" class="otp-input" maxlength="1">
  <input type="text" class="otp-input" maxlength="1">
  <input type="text" class="otp-input" maxlength="1">
</div>
```

#### Search (Busca)
```html
<input type="text" id="search-input" placeholder="Buscar...">
<button id="search-button">Buscar</button>
```

### 3. Alpine.js Components

O dropdown do Alpine.js está configurado automaticamente:

```html
<div x-data="dropdown">
  <button @click="toggle">Abrir Dropdown</button>
  <div x-ref="dropdown" x-show="open">
    <!-- Conteúdo do dropdown -->
  </div>
</div>
```

## Funcionalidades

### Inicialização Automática
- Todos os componentes são inicializados automaticamente
- Compatível com Turbo (navegação SPA)
- Reinicialização em mudanças de página

### Event Listeners
- `DOMContentLoaded` - Inicialização padrão
- `turbo:load` - Para navegação Turbo
- `turbo:render` - Para renderizações dinâmicas

### API Global
O TailAdmin Pro expõe uma API global para uso manual:

```javascript
// Reinicializar todos os componentes
window.TailAdminPro.initializeComponents();

// Inicializar componentes específicos
window.TailAdminPro.initializeFlatpickr();
window.TailAdminPro.initializeDropzone();
window.TailAdminPro.initializeCharts();
window.TailAdminPro.initializeOTP();
window.TailAdminPro.initializeCopy();
window.TailAdminPro.initializeSearch();
```

## Dependências

### NPM Packages
```json
{
  "alpinejs": "^3.14.9",
  "@alpinejs/persist": "^3.14.9",
  "flatpickr": "^4.6.13",
  "dropzone": "^6.0.0-beta.2",
  "apexcharts": "^3.51.0",
  "jsvectormap": "^1.6.0"
}
```

### CSS Dependencies
```javascript
import "flatpickr/dist/flatpickr.css";
import "dropzone/dist/dropzone.css";
import "jsvectormap/dist/jsvectormap.min.css";
```

## Troubleshooting

### Problemas Comuns

1. **Charts não aparecem**
   - Verifique se o elemento tem ID correto
   - Confirme se o ApexCharts está carregado

2. **Datepicker não funciona**
   - Verifique se a classe está correta (`datepicker` ou `datepickerTwo`)
   - Confirme se o flatpickr está importado

3. **Dropzone não inicializa**
   - Verifique se o elemento tem ID `demo-upload`
   - Confirme se a URL de upload está correta

### Debug
Abra o console do navegador para ver logs de inicialização:
- `🚀 TailAdmin Pro JS carregando...`
- `✅ Todos os componentes importados`
- `🔄 Inicializando componentes TailAdmin...`
- `✅ TailAdmin Pro inicializado com sucesso!`

## Personalização

### Adicionar Novos Charts
1. Crie o arquivo em `vendor/tailadmin-pro/js/components/charts/`
2. Importe no `tailadmin-pro.js`
3. Adicione à função `initializeCharts()`

### Configurar Novos Datepickers
```javascript
flatpickr(".meu-datepicker", {
  // configurações personalizadas
});
```

### Adicionar Novos Componentes
1. Crie o arquivo do componente
2. Importe no `tailadmin-pro.js`
3. Adicione à função `initializeTailAdminComponents()`

## Performance

- Todos os componentes são carregados de forma assíncrona
- Charts são inicializados apenas quando necessário
- CSS é otimizado com Vite
- Compatível com lazy loading

## Compatibilidade

- ✅ Rails 7+
- ✅ Vite
- ✅ Turbo
- ✅ Alpine.js 3.x
- ✅ Modern browsers (ES6+)
