# Configuração do Meilisearch

## Instalação

### 1. Instalar o Meilisearch

#### Via Docker (Recomendado)
```bash
docker run -p 7700:7700 getmeili/meilisearch:latest
```

#### Via Homebrew (macOS)
```bash
brew install meilisearch
meilisearch
```

#### Via Cargo (Rust)
```bash
cargo install meilisearch
meilisearch
```

### 2. Configurar Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto:

```bash
# Meilisearch Configuration
MEILISEARCH_HOST=http://localhost:7700
MEILISEARCH_API_KEY=YourMeilisearchAPIKey
```

### 3. Indexar Dados

Execute o comando rake para indexar todos os dados:

```bash
rails meilisearch:index
```

## Comandos Úteis

### Indexar dados
```bash
rails meilisearch:index
```

### Limpar índices
```bash
rails meilisearch:clear
```

### Resetar índices (limpar + indexar)
```bash
rails meilisearch:reset
```

## Configuração dos Modelos

### Professional
- **Campos pesquisáveis**: `full_name`, `email`, `cpf`, `phone`
- **Filtros**: `active`, `confirmed_at`
- **Ordenação**: `created_at`, `updated_at`, `full_name`

### Speciality
- **Campos pesquisáveis**: `name`, `specialty`
- **Filtros**: `created_at`, `updated_at`
- **Ordenação**: `created_at`, `updated_at`, `name`

### ContractType
- **Campos pesquisáveis**: `name`, `description`
- **Filtros**: `active`, `created_at`, `updated_at`
- **Ordenação**: `created_at`, `updated_at`, `name`

## Funcionalidades

### Busca em Tempo Real
- Debounce de 500ms para evitar muitas requisições
- Busca em múltiplos campos
- Highlight dos termos encontrados
- Fallback para busca local se Meilisearch não estiver disponível

### Interface
- Campo de busca integrado no componente DataTable
- Resultados atualizados dinamicamente
- Suporte a filtros avançados
- Ordenação por colunas

## Troubleshooting

### Meilisearch não está rodando
```bash
# Verificar se está rodando na porta 7700
curl http://localhost:7700/health
```

### Erro de conexão
- Verifique se o Meilisearch está rodando
- Confirme as variáveis de ambiente
- Teste a conexão: `curl http://localhost:7700/version`

### Dados não aparecem na busca
- Execute `rails meilisearch:index` para reindexar
- Verifique se os modelos têm dados
- Confirme a configuração dos campos pesquisáveis

## Desenvolvimento

### Logs do Meilisearch
```bash
# Se usando Docker
docker logs <container_id>

# Se rodando localmente
meilisearch --log-level debug
```

### Testar Busca
```bash
# Via curl
curl "http://localhost:7700/indexes/professional_development/search" \
  -H "Content-Type: application/json" \
  -d '{"q": "joão"}'
```

### Dashboard do Meilisearch
Acesse `http://localhost:7700` para ver o dashboard do Meilisearch e gerenciar índices.
