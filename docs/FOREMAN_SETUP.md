# Configuração do Foreman

## O que é o Foreman?

O Foreman é uma ferramenta que permite gerenciar múltiplos processos de desenvolvimento simultaneamente. No nosso projeto, ele inicia:

- **Rails Server** (porta 3000) - Servidor principal da aplicação
- **Vite Dev Server** (porta 5173) - Servidor de desenvolvimento para assets
- **Solid Queue Jobs** - Processamento de jobs em background
- **MeiliSearch** (porta 7700) - Motor de busca

## Como Usar

### Método 1: Script Automatizado (Recomendado)

```bash
# Inicia todos os serviços automaticamente
./bin/dev
```

### Método 2: Foreman Direto

```bash
# Configurar variáveis de ambiente
source bin/setup-db

# Iniciar com Foreman
foreman start -f Procfile.dev
```

### Método 3: Serviços Individuais

```bash
# Terminal 1: Rails Server
source bin/setup-db && bin/rails server -p 3000

# Terminal 2: Vite Dev Server
bin/vite dev

# Terminal 3: Jobs
source bin/setup-db && bin/rails solid_queue:start

# Terminal 4: MeiliSearch
meilisearch --http-addr 127.0.0.1:7700 --env development --db-path ./storage/meilisearch --master-key XAXESpKGcHHdauFVvOKlRyWsgMfX0xv513anuJ-_i9w
```

## Configuração

### Arquivo .env

O arquivo `.env` contém as variáveis de ambiente necessárias:

```bash
DATABASE_USERNAME=pedro
DATABASE_PASSWORD=
ASDF_SILENCE_WARNING=1
MEILISEARCH_HOST=http://localhost:7700
MEILISEARCH_API_KEY=XAXESpKGcHHdauFVvOKlRyWsgMfX0xv513anuJ-_i9w
```

### Procfile.dev

```bash
web: bin/rails server -p 3000
vite: bin/vite dev
jobs: bin/rails solid_queue:start
meilisearch: meilisearch --http-addr 127.0.0.1:7700 --env development --db-path ./storage/meilisearch --master-key XAXESpKGcHHdauFVvOKlRyWsgMfX0xv513anuJ-_i9w
```

## URLs de Acesso

- **Aplicação Principal**: http://localhost:3000
- **Vite Dev Server**: http://localhost:5173
- **MeiliSearch**: http://localhost:7700

## Comandos Úteis

```bash
# Verificar se os serviços estão rodando
ps aux | grep -E "(rails|vite|solid_queue|meilisearch)" | grep -v grep

# Parar todos os serviços
pkill -f "rails server"
pkill -f "vite"
pkill -f "solid_queue"
pkill -f "meilisearch"

# Verificar logs do Foreman
foreman start -f Procfile.dev --log
```

## Solução de Problemas

### Erro: "Cannot find package 'vite'"

```bash
# Instalar dependências do Node.js
npm install
```

### Erro: "Database connection failed"

```bash
# Verificar se o PostgreSQL está rodando
sudo systemctl status postgresql

# Configurar variáveis de ambiente
source bin/setup-db
```

### Erro: "Port already in use"

```bash
# Encontrar processo usando a porta
lsof -i :3000
lsof -i :5173
lsof -i :7700

# Matar processo
kill -9 <PID>
```

### Erro: "Address already in use" (MeiliSearch)

```bash
# Parar processo do MeiliSearch
pkill meilisearch

# Verificar se a porta está livre
lsof -i :7700
```

## Dependências

- **Foreman**: `gem install foreman`
- **Node.js**: Instalado via asdf
- **PostgreSQL**: Configurado e rodando
- **MeiliSearch**: Instalado em `/usr/local/bin/meilisearch`

## Notas Importantes

1. Sempre execute `source bin/setup-db` antes de iniciar os serviços
2. O arquivo `.env` é carregado automaticamente pelo Foreman
3. Para desenvolvimento, use `./bin/dev` para facilitar o processo
4. Os logs de todos os serviços aparecem no mesmo terminal quando usando Foreman
5. O MeiliSearch armazena seus dados no diretório `./storage/meilisearch` do projeto
6. O diretório `data.ms/` está no `.gitignore` para evitar commit acidental dos dados

## Estrutura de Dados

```
storage/
├── meilisearch/          # Dados do MeiliSearch
│   ├── auth/            # Autenticação
│   ├── indexes/         # Índices de busca
│   ├── tasks/           # Tarefas em processamento
│   ├── update_files/    # Arquivos de atualização
│   ├── instance-uid     # ID da instância
│   └── VERSION          # Versão do banco de dados
└── documents/           # Documentos do sistema (se houver)
```
