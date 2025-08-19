# 📋 Regras do Projeto IntegrarPlus

## 🎯 Objetivo
Este documento define as convenções, padrões e regras que devem ser seguidas no desenvolvimento do projeto IntegrarPlus.

## 🏗️ Arquitetura Frontend

### Estrutura de Pastas
```
app/frontend/
├── entrypoints/           # Entry points do Vite
│   └── application.js     # Entry point principal
├── javascript/
│   ├── controllers/       # Stimulus controllers
│   ├── application.js     # Configuração Stimulus
│   └── tailadmin-pro/     # Componentes TailAdmin
│       ├── index.js       # Módulo central
│       └── components/    # Componentes específicos
├── styles/
│   ├── application.css    # Estilos principais
│   └── tailadmin-pro.css  # Estilos TailAdmin
└── assets/               # Assets estáticos
```

### Convenções de Nomenclatura
- **Arquivos JavaScript**: `kebab-case.js`
- **Componentes**: `component-name.js`
- **Controllers Stimulus**: `component_controller.js`
- **CSS**: `kebab-case.css`

## 🧩 Componentização

### Princípios
1. **Componentização criteriosa**: Criar componentes apenas quando reutilizáveis
2. **Evitar componentes desnecessários**: Não criar componentes para lógica simples
3. **Padrão de função**: Todos os componentes exportam uma função que verifica existência do elemento

### Padrão de Componente TailAdmin
```javascript
// components/widget-name.js
export default function widgetName() {
  const el = document.querySelector("#widget-selector");
  if (!el) return;
  
  // inicialização do widget
}
```

### Padrão de Controller Stimulus
```javascript
// controllers/widget_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // inicialização
  }
  
  disconnect() {
    // limpeza
  }
}
```

## 🎨 UI/UX

### Design System
- **Profissional**: Interfaces completas e elegantes
- **Moderno**: Design atual e sofisticado
- **Responsivo**: Funcionamento em todos os dispositivos
- **Acessível**: Seguir padrões de acessibilidade

### Framework CSS
- **Tailwind CSS**: Framework principal
- **TailAdmin Pro**: Template base
- **Componentes customizados**: Quando necessário

## 🔧 Tecnologias

### Frontend
- **Rails 7**: Framework backend
- **Hotwire/Turbo**: Navegação SPA
- **Stimulus**: Controllers JavaScript
- **Alpine.js**: Interatividade (via TailAdmin)
- **Vite**: Build tool
- **Tailwind CSS**: Framework CSS

### Bibliotecas JavaScript
- **ApexCharts**: Gráficos
- **Swiper**: Carousels
- **Flatpickr**: Datepickers
- **Dropzone**: Upload de arquivos
- **FullCalendar**: Calendários
- **jsVectorMap**: Mapas vetoriais

## 📁 Organização de Componentes

### Componentes Específicos
- **Login**: `app/frontend/javascript/login/`
- **Dashboard**: `app/frontend/javascript/dashboard/`
- **Admin**: `app/frontend/javascript/admin/`

### Componentes Compartilhados
- **Shared**: `app/frontend/javascript/shared/`
- **UI**: `app/frontend/javascript/shared/ui/`
- **Utils**: `app/frontend/javascript/shared/utils/`

## 🔄 Integração TailAdmin + Turbo

### Princípios
1. **Idempotência**: `bootTailadmin()` pode ser chamada múltiplas vezes sem efeitos colaterais
2. **Verificação de existência**: Componentes só inicializam se elementos existirem
3. **Limpeza**: Destruir instâncias anteriores antes de recriar
4. **Compatibilidade**: Funcionar com todas as navegações Turbo

### Padrão de Inicialização
```javascript
// Verificação de existência
const el = document.querySelector("#element");
if (!el) return;

// Limpeza de instâncias anteriores
if (el._instance) el._instance.destroy();

// Inicialização segura
const safe = (fn) => { try { fn?.(); } catch (_) {} };
```

## 📝 Documentação

### Arquivos Obrigatórios
- **README.md**: Documentação principal do componente
- **PROJECT_RULES.md**: Regras do projeto (este arquivo)
- **CHANGELOG.md**: Histórico de mudanças

### Padrão de Documentação
```markdown
# Nome do Componente

## Descrição
Breve descrição do que o componente faz.

## Uso
```html
<div id="component-id">
  <!-- estrutura HTML -->
</div>
```

## Dependências
- Lista de dependências externas

## Configuração
Parâmetros de configuração disponíveis.
```

## 🔄 Versionamento

### Commits
- **Convencional**: Usar Conventional Commits
- **Frequente**: Commits pequenos e frequentes
- **Descritivo**: Mensagens claras e específicas

### Exemplos de Commits
```
feat: adiciona componente de gráfico de vendas
fix: corrige inicialização do flatpickr após navegação
docs: atualiza documentação do TailAdmin
refactor: reorganiza estrutura de componentes
```

## 🧪 Testes

### Cobertura
- **JavaScript**: Testes unitários para lógica complexa
- **Integração**: Testes de integração para componentes
- **E2E**: Testes end-to-end para fluxos críticos

### Ferramentas
- **Jest**: Testes unitários
- **Capybara**: Testes E2E
- **RSpec**: Testes de integração

## 🚀 Deploy

### Build
- **Vite**: Build otimizado para produção
- **Assets**: Minificação e compressão
- **Cache**: Estratégias de cache adequadas

### Monitoramento
- **Performance**: Monitorar métricas de performance
- **Erros**: Logging de erros JavaScript
- **Analytics**: Tracking de uso

## 🔒 Segurança

### Frontend
- **CSRF**: Tokens CSRF em todas as requisições
- **XSS**: Sanitização de dados
- **CSP**: Content Security Policy
- **HTTPS**: Sempre usar HTTPS em produção

### Dependências
- **Auditoria**: Verificar vulnerabilidades regularmente
- **Atualizações**: Manter dependências atualizadas
- **Licenças**: Verificar licenças de dependências

## 📊 Performance

### Métricas
- **First Contentful Paint**: < 1.5s
- **Largest Contentful Paint**: < 2.5s
- **Cumulative Layout Shift**: < 0.1
- **First Input Delay**: < 100ms

### Otimizações
- **Lazy Loading**: Carregar componentes sob demanda
- **Code Splitting**: Dividir código em chunks
- **Tree Shaking**: Remover código não utilizado
- **Caching**: Estratégias de cache eficientes

## 🤝 Contribuição

### Processo
1. **Fork**: Fazer fork do repositório
2. **Branch**: Criar branch para feature/fix
3. **Desenvolvimento**: Seguir regras do projeto
4. **Testes**: Executar testes antes do commit
5. **Pull Request**: Criar PR com descrição clara
6. **Review**: Aguardar review e aprovação

### Padrões de Código
- **ESLint**: Seguir regras do ESLint
- **Prettier**: Formatação consistente
- **TypeScript**: Usar quando possível
- **Comentários**: Documentar código complexo

---

**Última atualização**: Dezembro 2024
**Versão**: 1.0.0
