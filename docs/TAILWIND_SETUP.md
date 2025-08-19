# Configuração do Tailwind CSS v4 no Rails 8

## Visão Geral

Este projeto está configurado com Tailwind CSS v4 usando Vite como bundler. A configuração segue as melhores práticas para Rails 8.

## Estrutura de Arquivos

```
app/frontend/
├── entrypoints/
│   └── application.css          # Entrypoint principal com @import "tailwindcss"
├── styles/
│   └── application.css          # Estilos customizados
└── stylesheets/
    └── application.tailwind.css # Arquivo específico do Tailwind (não usado)

config/
└── vite.config.mts             # Configuração do Vite com plugin Tailwind

tailwind.config.mjs             # Configuração do Tailwind CSS
```

## Configuração Principal

### 1. Vite Config (vite.config.mts)

```typescript
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    tailwindcss(),
  ],
})
```

### 2. Entrypoint CSS (app/frontend/entrypoints/application.css)

```css
@import "tailwindcss";
@import "../styles/application.css";
```

### 3. Layout Application (app/views/layouts/application.html.erb)

```erb
<%= vite_client_tag %>
<%= vite_stylesheet_tag "entrypoints/application" %>
<%= vite_javascript_tag "entrypoints/application" %>
```

### 4. Tailwind Config (tailwind.config.mjs)

```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './app/views/**/*.{erb,html}',
    './app/components/**/*.{erb,html,rb}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/frontend/**/*.{js,css}'
  ],
  theme: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}
```

## Dependências

### package.json
```json
{
  "dependencies": {
    "@tailwindcss/forms": "^0.5.10",
    "@tailwindcss/vite": "^4.1.12",
    "tailwindcss": "^4.1.12"
  },
  "devDependencies": {
    "autoprefixer": "^10.4.19"
  }
}
```

## Como Usar

### 1. Classes Básicas
```html
<div class="bg-blue-500 text-white p-4 rounded-lg">
  Conteúdo com Tailwind
</div>
```

### 2. Responsividade
```html
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
  <!-- Grid responsivo -->
</div>
```

### 3. Estados
```html
<button class="bg-blue-500 hover:bg-blue-600 focus:ring-2 focus:ring-blue-300">
  Botão interativo
</button>
```

## Teste da Configuração

Para testar se o Tailwind está funcionando, acesse:
```
http://localhost:3000/test-tailwind
```

Esta página demonstra:
- Cores e gradientes
- Layout responsivo
- Componentes interativos
- Tipografia
- Espaçamentos

## Solução de Problemas

### Tailwind não está funcionando?

1. **Verifique se o Vite está rodando:**
   ```bash
   bin/dev
   ```

2. **Verifique se os arquivos CSS estão sendo carregados:**
   - Abra o DevTools do navegador
   - Vá para a aba Network
   - Recarregue a página
   - Procure por arquivos CSS sendo carregados

3. **Verifique se o vite_stylesheet_tag está presente:**
   ```erb
   <%= vite_stylesheet_tag "entrypoints/application" %>
   ```

4. **Verifique se a importação do Tailwind está correta:**
   ```css
   @import "tailwindcss";
   ```

### Classes não estão sendo aplicadas?

1. **Verifique o content no tailwind.config.mjs:**
   - Certifique-se de que os caminhos incluem seus arquivos

2. **Limpe o cache do Vite:**
   ```bash
   rm -rf tmp/cache
   bin/dev
   ```

## Recursos Adicionais

- [Documentação oficial do Tailwind CSS v4](https://tailwindcss.com/docs)
- [Guia do Vite com Rails](https://vite-ruby.netlify.app/)
- [Plugin Tailwind para Vite](https://github.com/tailwindlabs/tailwindcss/tree/master/packages/vite)
