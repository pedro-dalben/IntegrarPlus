# Configuração de Linters - IntegrarPlus

Este documento descreve a configuração dos linters e ferramentas de qualidade de código no projeto IntegrarPlus.

## 🛠️ Ferramentas Configuradas

### 1. ESLint (JavaScript)
- **Versão**: 9.34.0
- **Configuração**: `eslint.config.js`
- **Foco**: Apenas arquivos JavaScript do projeto (ignora vendor/)

#### Regras Principais:
- `no-console`: Warning (permite console.log com aviso)
- `no-debugger`: Error
- `no-alert`: Error
- `prefer-const`: Error
- `prefer-arrow-callback`: Error
- `object-shorthand`: Error
- `prefer-template`: Error
- `no-unused-vars`: Error (com exceção para parâmetros que começam com `_`)

#### Arquivos Ignorados:
- `node_modules/**/*`
- `vendor/**/*`
- `public/assets/**/*`
- `public/vite-dev/**/*`
- `*.min.js`, `*.bundle.js`, `*.vendor.js`

### 2. Prettier (Formatação)
- **Versão**: 3.6.2
- **Configuração**: `.prettierrc`
- **Foco**: JavaScript, HTML, ERB

#### Configurações:
- `semi`: true
- `singleQuote`: true
- `printWidth`: 100
- `tabWidth`: 2
- `trailingComma`: "es5"

### 3. RuboCop (Ruby)
- **Configuração**: `.rubocop.yml`
- **Foco**: Código Ruby do projeto

#### Configurações Principais:
- `Layout/LineLength`: Max 120 caracteres
- `NewCops`: enable
- Plugins: `rubocop-rails`, `rubocop-performance`

## 📜 Scripts Disponíveis

### Verificação Completa
```bash
./bin/lint
```
Executa todos os linters em sequência:
1. ESLint (JavaScript)
2. Prettier (formatação)
3. RuboCop (Ruby)

### Auto-correção
```bash
./bin/fix
```
Corrige automaticamente problemas que podem ser resolvidos:
1. ESLint --fix
2. Prettier --write
3. RuboCop -a

### Scripts NPM
```bash
# Verificar JavaScript
npm run lint

# Corrigir JavaScript
npm run lint:fix

# Verificar formatação
npm run format:check

# Formatar código
npm run format

# Verificar tudo
npm run check
```

## 🎯 Como Usar

### Durante o Desenvolvimento
1. **Antes de commitar**: Execute `./bin/lint` para verificar problemas
2. **Para corrigir automaticamente**: Execute `./bin/fix`
3. **Para verificar apenas JavaScript**: `npm run lint`
4. **Para verificar apenas Ruby**: `bundle exec rubocop`

### Integração com IDE
- **VS Code**: Instale as extensões ESLint e Prettier
- **RubyMine**: RuboCop já está integrado
- **Vim/Neovim**: Configure plugins para ESLint e RuboCop

## 📋 Problemas Comuns

### ESLint
- **"no-undef" errors**: Para arquivos do browser, adicione `/* global window, document */` no topo
- **"no-unused-vars"**: Use `_` como prefixo para parâmetros não utilizados

### Prettier
- **Conflitos com ESLint**: Use `eslint-config-prettier` (já configurado)
- **Arquivos ignorados**: Verifique `.prettierignore`

### RuboCop
- **Muitas violações**: Use `bundle exec rubocop -a` para auto-correção
- **Ignorar regras específicas**: Use `# rubocop:disable RuleName`

## 🔧 Personalização

### Adicionar Novas Regras ESLint
Edite `eslint.config.js` e adicione regras na seção `rules`.

### Modificar Configuração Prettier
Edite `.prettierrc` para ajustar formatação.

### Ajustar RuboCop
Edite `.rubocop.yml` para modificar regras Ruby.

## 📚 Recursos Adicionais

- [ESLint Documentation](https://eslint.org/)
- [Prettier Documentation](https://prettier.io/)
- [RuboCop Documentation](https://rubocop.org/)

## 🚀 Próximos Passos

1. **Integração com CI/CD**: Adicionar linters ao pipeline
2. **Pre-commit hooks**: Configurar hooks para executar linters automaticamente
3. **Métricas de qualidade**: Implementar relatórios de qualidade de código
4. **Padronização de equipe**: Documentar convenções específicas do projeto
