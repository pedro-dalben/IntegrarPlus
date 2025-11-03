# Gerenciamento de Seeds em Produção

## Visão Geral

Sistema para gerenciar seeds que precisam ser executados em produção durante o `reload-vps`, evitando que seeds pendentes sejam esquecidos.

## Como Funciona

1. **Adicionar seed à fila**: `rails seeds:add[arquivo]`
2. **Executar no reload-vps**: O script `bin/reload-vps` executa automaticamente os seeds pendentes
3. **Remoção automática**: Seeds executados com sucesso são removidos da fila automaticamente

## Comandos Disponíveis

### Listar Seeds Pendentes

```bash
rails seeds:list
```

Mostra todos os seeds que estão na fila de execução.

### Adicionar Seed à Fila

```bash
rails seeds:add[db/seeds/meu_seed.rb]
```

Adiciona um seed à fila de execução. O seed será executado no próximo `reload-vps`.

**Exemplo:**
```bash
rails seeds:add[db/seeds/beneficiary_tabs_permissions.rb]
```

### Remover Seed da Fila

```bash
rails seeds:remove[db/seeds/meu_seed.rb]
```

Remove um seed da fila de execução sem executá-lo.

### Executar Seeds Pendentes Manualmente

```bash
rails seeds:execute_pending
```

Executa todos os seeds pendentes imediatamente (fora do processo de reload).

### Limpar Todas as Seeds Pendentes

```bash
rails seeds:clear
```

⚠️ **CUIDADO**: Remove todas as seeds da fila sem executá-las.

## Integração com reload-vps

O script `bin/reload-vps` executa automaticamente:

1. ✅ `rails seeds:execute_pending` - Executa seeds pendentes
2. ✅ `rails db:migrate` - Executa migrations

Se algum seed falhar, o processo continua, mas o seed permanece na fila para correção.

## Fluxo de Trabalho Recomendado

### 1. Desenvolvimento

```bash
# Criar o seed
# ... editar db/seeds/meu_seed.rb ...

# Adicionar à fila para produção
rails seeds:add[db/seeds/meu_seed.rb]

# Verificar
rails seeds:list
```

### 2. Antes do Deploy

```bash
# Verificar checklist
rails deploy:pre_reload_check
```

Isso mostra:
- Migrations pendentes
- Seeds pendentes

### 3. No VPS (durante reload-vps)

O script executa automaticamente:
```bash
bin/reload-vps
```

Saída esperada:
```
🌱 Executando seeds pendentes...
Executing 1 pending seed(s)...

▶️  Executing: beneficiary_tabs_permissions (db/seeds/beneficiary_tabs_permissions.rb)
✅ Success: beneficiary_tabs_permissions
   Removed db/seeds/beneficiary_tabs_permissions.rb from queue (execution successful)

✅ All 1 seed(s) executed successfully and removed from queue
```

### 4. Após Deploy

```bash
# Verificar se não há seeds pendentes
rails seeds:list
```

Se houver erro:
```bash
# Corrigir o seed
# ... editar db/seeds/meu_seed.rb ...

# Executar novamente
rails seeds:execute_pending
```

## Arquivo de Controle

O sistema usa o arquivo `.pending_production_seeds` na raiz do projeto para manter a fila. Este arquivo:

- ✅ Está no `.gitignore` (não vai para o repositório)
- ✅ Contém paths absolutos dos seeds
- ✅ É criado automaticamente quando necessário
- ✅ É removido automaticamente quando a fila fica vazia

**Exemplo de conteúdo:**
```
/home/ubuntu/IntegrarPlus/db/seeds/beneficiary_tabs_permissions.rb
/home/ubuntu/IntegrarPlus/db/seeds/outro_seed.rb
```

## Troubleshooting

### Seed não executa

1. Verificar se o seed está na fila: `rails seeds:list`
2. Verificar se o arquivo existe e está acessível
3. Executar manualmente: `rails seeds:execute_pending`
4. Verificar erros no output

### Seed falha durante reload-vps

O seed permanece na fila. Corrija o erro e execute novamente:
```bash
rails seeds:execute_pending
```

Ou remova manualmente se não for mais necessário:
```bash
rails seeds:remove[db/seeds/meu_seed.rb]
```

## Exemplos Práticos

### Adicionar permissões novas

```bash
# 1. Criar seed com as permissões
# ... db/seeds/new_permissions.rb ...

# 2. Adicionar à fila
rails seeds:add[db/seeds/new_permissions.rb]

# 3. Verificar
rails seeds:list

# 4. No próximo reload-vps, será executado automaticamente
```

### Adicionar usuário de teste (temporário)

```bash
rails seeds:add[db/seeds/test_user.rb]

# Após verificar em produção, remover
rails seeds:remove[db/seeds/test_user.rb]
```

## Referências

- Rake tasks: `lib/tasks/seeds_manager.rake`
- Reload script: `bin/reload-vps`
- Rake reload: `lib/tasks/reload_vps.rake`
