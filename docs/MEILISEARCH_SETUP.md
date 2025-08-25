# Configuração do MeiliSearch

## Visão Geral

O MeiliSearch é um motor de busca rápido e relevante que está integrado ao projeto Integrar Plus. Ele fornece funcionalidades de busca avançada para documentos e outros conteúdos do sistema.

## Configuração Atual

### Localização dos Dados
- **Diretório**: `./storage/meilisearch/`
- **Porta**: 7700
- **URL**: http://localhost:7700
- **Master Key**: `XAXESpKGcHHdauFVvOKlRyWsgMfX0xv513anuJ-_i9w`

### Estrutura de Dados
```
storage/meilisearch/
├── auth/            # Configurações de autenticação
├── indexes/         # Índices de busca criados
├── tasks/           # Tarefas em processamento
├── update_files/    # Arquivos de atualização
├── instance-uid     # ID único da instância
└── VERSION          # Versão do banco de dados
```

## Como Usar

### Iniciar com Foreman (Recomendado)
```bash
# Inicia todos os serviços incluindo MeiliSearch
./bin/dev

# Ou manualmente
foreman start -f Procfile.dev
```

### Iniciar Individualmente
```bash
meilisearch --http-addr 127.0.0.1:7700 --env development --db-path ./storage/meilisearch --master-key XAXESpKGcHHdauFVvOKlRyWsgMfX0xv513anuJ-_i9w
```

## Verificação de Status

### Verificar se está rodando
```bash
# Verificar processo
ps aux | grep meilisearch | grep -v grep

# Verificar porta
lsof -i :7700

# Testar endpoint de saúde
curl -s http://localhost:7700/health
```

### Verificar versão (requer autenticação)
```bash
curl -H "Authorization: Bearer XAXESpKGcHHdauFVvOKlRyWsgMfX0xv513anuJ-_i9w" http://localhost:7700/version
```

## Configuração no Rails

### Variáveis de Ambiente
```bash
MEILISEARCH_HOST=http://localhost:7700
MEILISEARCH_API_KEY=XAXESpKGcHHdauFVvOKlRyWsgMfX0xv513anuJ-_i9w
```

### Arquivo de Configuração
```ruby
# config/initializers/meilisearch.rb
Meilisearch::Rails.configuration = {
  meilisearch_url: ENV.fetch('MEILISEARCH_HOST', 'http://localhost:7700'),
  meilisearch_api_key: ENV.fetch('MEILISEARCH_API_KEY', 'XAXESpKGcHHdauFVvOKlRyWsgMfX0xv513anuJ-_i9w')
}
```

## Solução de Problemas

### Erro: "Address already in use"
```bash
# Parar processo do MeiliSearch
pkill meilisearch

# Verificar se a porta está livre
lsof -i :7700
```

### Erro: "Permission denied"
```bash
# Verificar permissões do diretório
ls -la storage/meilisearch/

# Corrigir permissões se necessário
chmod -R 755 storage/meilisearch/
```

### Erro: "Database path not found"
```bash
# Criar diretório se não existir
mkdir -p storage/meilisearch
```

### Erro: "Authorization header missing"
```bash
# Adicionar header de autorização nas requisições
curl -H "Authorization: Bearer XAXESpKGcHHdauFVvOKlRyWsgMfX0xv513anuJ-_i9w" http://localhost:7700/version
```

## Backup e Restauração

### Backup dos Dados
```bash
# Fazer backup do diretório de dados
tar -czf meilisearch-backup-$(date +%Y%m%d).tar.gz storage/meilisearch/
```

### Restauração dos Dados
```bash
# Parar MeiliSearch
pkill meilisearch

# Restaurar dados
tar -xzf meilisearch-backup-YYYYMMDD.tar.gz

# Reiniciar MeiliSearch
./bin/dev
```

## Limpeza de Dados

### Limpar todos os dados
```bash
# Parar MeiliSearch
pkill meilisearch

# Remover diretório de dados
rm -rf storage/meilisearch/*

# Reiniciar (criará nova instância)
./bin/dev
```

### Limpar apenas índices
```bash
# Via API (requer autenticação)
curl -X DELETE -H "Authorization: Bearer XAXESpKGcHHdauFVvOKlRyWsgMfX0xv513anuJ-_i9w" http://localhost:7700/indexes
```

## Monitoramento

### Logs em Tempo Real
```bash
# Ver logs do Foreman
foreman start -f Procfile.dev

# Ou ver logs específicos do MeiliSearch
tail -f storage/meilisearch/*.log
```

### Métricas de Performance
```bash
# Ver estatísticas (requer autenticação)
curl -H "Authorization: Bearer XAXESpKGcHHdauFVvOKlRyWsgMfX0xv513anuJ-_i9w" http://localhost:7700/stats
```

## Notas Importantes

1. **Dados Persistentes**: Os dados do MeiliSearch são mantidos entre reinicializações
2. **Git Ignore**: O diretório `data.ms/` está no `.gitignore` para evitar commit acidental
3. **Autenticação**: Todas as requisições à API precisam do header de autorização
4. **Desenvolvimento**: Configurado para ambiente de desenvolvimento
5. **Integração**: Integrado automaticamente com o Foreman para facilitar o desenvolvimento

## Recursos Adicionais

- [Documentação Oficial do MeiliSearch](https://docs.meilisearch.com/)
- [API Reference](https://docs.meilisearch.com/reference/api/)
- [Ruby SDK](https://github.com/meilisearch/meilisearch-ruby)
