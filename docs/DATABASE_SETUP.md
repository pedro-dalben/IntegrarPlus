# Configuração do Banco de Dados PostgreSQL

## Problema Resolvido

O projeto estava enfrentando problemas para conectar ao PostgreSQL devido à configuração de autenticação que exigia senha para conexões locais.

## Solução Implementada

### 1. Configuração do PostgreSQL

Modificamos o arquivo `/etc/postgresql/16/main/pg_hba.conf` para permitir conexões locais sem senha:

```bash
# Backup da configuração original
sudo cp /etc/postgresql/16/main/pg_hba.conf /etc/postgresql/16/main/pg_hba.conf.backup

# Modificação da linha de autenticação
sudo sed -i 's/host    all             all             127.0.0.1\/32            scram-sha-256/host    all             all             127.0.0.1\/32            trust/' /etc/postgresql/16/main/pg_hba.conf

# Reiniciar o PostgreSQL
sudo systemctl restart postgresql
```

### 2. Variáveis de Ambiente

O projeto utiliza as seguintes variáveis de ambiente para conexão com o banco:

- `DATABASE_USERNAME=pedro`
- `DATABASE_PASSWORD=` (vazio)

### 3. Script de Configuração

Criamos o script `bin/setup-db` para facilitar a configuração das variáveis de ambiente:

```bash
# Configurar variáveis de ambiente
source bin/setup-db

# Criar banco de dados
bundle exec rails db:create

# Executar migrações
bundle exec rails db:migrate

# Executar migrações das filas
bundle exec rails db:migrate:queue
```

## Bancos de Dados Criados

- `integrar_plus_development` - Banco principal de desenvolvimento
- `integrar_plus_development_queue` - Banco para filas de processamento
- `integrar_plus_test` - Banco para testes

## Verificação

Para verificar se tudo está funcionando:

```bash
source bin/setup-db
bundle exec rails db:version
```

## Notas Importantes

1. A configuração `trust` permite conexões sem senha apenas para localhost (127.0.0.1)
2. Para produção, recomenda-se usar autenticação mais segura
3. O backup da configuração original está em `/etc/postgresql/16/main/pg_hba.conf.backup`
