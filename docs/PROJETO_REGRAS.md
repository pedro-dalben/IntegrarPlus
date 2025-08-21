# Regras do Projeto IntegrarPlus

## 📋 Padrões de Layout

### Layout Padrão para CRUD
- **@products-list.html**: Padrão para telas de listagem/índice
- **@add-product.html**: Padrão para telas de criação e edição (formulários)

### Estrutura de Cards
- Usar sempre `rounded-2xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-white/[0.03]`
- Seções dentro do card usam `border-b border-gray-200 px-6 py-4 dark:border-gray-800` para cabeçalhos
- Conteúdo dentro usa `p-4 sm:p-6`

### Botões
- Usar classes `ta-btn` como base
- Variações: `ta-btn-primary`, `ta-btn-secondary`, `ta-btn-success`
- Tamanhos: `ta-btn-sm` para botões menores
- Sempre incluir ícones SVG apropriados

## 👥 Gestão de Usuários

### Acesso via Profissional
- Usuários não possuem index próprio
- Sempre acessar usuários através do profissional associado
- Navegação: Profissionais → Ver/Editar → Usuário

### Criação de Links de Convite
- Botão "Gerar Link" sempre disponível na tela de profissional
- Aparece na seção "Acesso e Status"
- Só exibir se usuário não confirmou convite
- Processo fluido: Criar Profissional → Gerar Link → Enviar por e-mail

## 🎨 Componentes UI

### ViewComponent + Stimulus
- Usar ViewComponent para componentes reutilizáveis
- Stimulus (não Alpine.js) para interatividade JavaScript
- Layout principal via `::Layouts::AdminComponent`

### Classes TailAdmin
- Todas as classes customizadas começam com `ta-`
- Definidas em `app/frontend/stylesheets/components/_tailadmin.scss`
- Suporte automático para modo escuro

## 🔐 Senhas e Convites

### Geração de Senhas
- Senhas não são definidas no formulário de criação/edição
- Sempre geradas via link de convite
- Usuário define própria senha através do link

### Fluxo de Convites
1. Admin cria/edita profissional
2. Sistema cria usuário automaticamente
3. Admin gera link de convite
4. Usuário recebe link por e-mail
5. Usuário define senha e acessa sistema

## 📁 Organização de Código

### Estrutura de Pastas
- Componentes específicos de login: `app/components/login/`
- Componentes compartilhados: `app/components/shared/`
- Componentização criteriosa: apenas quando reutilizável

### Documentação
- Cada componente deve ter arquivo `.md` com detalhes de uso
- Documentar convenções e padrões
- Commits regulares das alterações

## 🚫 Restrições

### Commits
- Nunca fazer commit sem confirmação do usuário
- Sempre confirmar que alterações estão corretas
- Aguardar aprovação explícita

### Comentários no Código
- Não escrever comentários no código
- Documentação externa via arquivos `.md`

### Componentização
- Evitar componentes desnecessários
- Criar apenas quando há reutilização real
- Manter código simples quando possível
