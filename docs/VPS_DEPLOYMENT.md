# 🚀 Guia de Deploy e Gerenciamento na VPS (Produção)

## 📋 Visão Geral

Este documento descreve como gerenciar o projeto IntegrarPlus na VPS Ubuntu em modo **PRODUÇÃO**, incluindo execução de migrations, controle do servidor Puma e recarregamento de assets.

## 🔗 Conexão SSH

```bash
ssh ubuntu1
cd /home/pedro/Documents/integrar/IntegrarPlus
```

## 🗄️ Gerenciamento de Database

### Configuração de Variáveis de Ambiente

Antes de executar qualquer comando relacionado ao banco de dados, configure as variáveis de ambiente:

```bash
source bin/setup-db
```

Isso configura:
- `DATABASE_USERNAME=pedro`
- `DATABASE_PASSWORD=""`
- `ASDF_SILENCE_WARNING=1`

### Executando Migrations

#### 1. Migrations Principais
```bash
# Configurar variáveis e executar migrations
source bin/setup-db && bundle exec rails db:migrate
```

#### 2. Migrations de Queue (Background Jobs)
```bash
source bin/setup-db && bundle exec rails db:migrate:queue
```

#### 3. Migrations de Cache
```bash
source bin/setup-db && bundle exec rails db:migrate:cache
```

#### 4. Migrations de Cable (WebSocket)
```bash
source bin/setup-db && bundle exec rails db:migrate:cable
```

#### 5. Todas as Migrations de Uma Vez
```bash
source bin/setup-db && bundle exec rails db:migrate:all
```

### Comandos Úteis do Database

```bash
# Verificar status das migrations
source bin/setup-db && bundle exec rails db:migrate:status

# Rollback da última migration
source bin/setup-db && bundle exec rails db:rollback

# Reset completo do banco (CUIDADO!)
source bin/setup-db && bundle exec rails db:drop db:create db:migrate db:seed

# Backup do banco
source bin/setup-db && pg_dump -U pedro integrar_plus_production > backup_$(date +%Y%m%d_%H%M%S).sql

# Restaurar backup
source bin/setup-db && psql -U pedro integrar_plus_production < backup_file.sql
```

## 🖥️ Controle do Servidor (Produção)

### Configuração de Ambiente

Antes de iniciar o servidor, configure o ambiente de produção:

```bash
# Configurar variáveis de ambiente
export RAILS_ENV=production
export RAILS_SERVE_STATIC_FILES=true
export RAILS_LOG_TO_STDOUT=true

# Ou usar o script de configuração
source bin/setup-production
```

### Iniciando o Servidor

#### Opção 1: Servidor Puma (Recomendado)
```bash
# Iniciar servidor Puma em produção
bundle exec rails server -e production -p 3000
```

#### Opção 2: Puma com Configuração Específica
```bash
# Iniciar Puma com configurações otimizadas
bundle exec puma -e production -p 3000 -w 2 -t 5:5
```

#### Opção 3: Servidor em Background
```bash
# Iniciar em background com nohup
nohup bundle exec rails server -e production -p 3000 > log/production.log 2>&1 &

# Verificar se está rodando
ps aux | grep puma
```

#### Opção 4: Usando Systemd (Recomendado para VPS)
```bash
# Criar serviço systemd
sudo systemctl enable integrar-plus
sudo systemctl start integrar-plus
sudo systemctl status integrar-plus
```

### Parando o Servidor

#### Se iniciado com Puma:
```bash
# Pressionar Ctrl+C no terminal onde está rodando
```

#### Se iniciado em background:
```bash
# Encontrar o processo Puma
ps aux | grep puma

# Matar o processo (substitua PID pelo número do processo)
kill -TERM PID

# Forçar parada se necessário
kill -KILL PID
```

#### Parar todos os processos Rails/Puma:
```bash
pkill -f "rails server"
pkill -f "puma"
```

#### Se usando Systemd:
```bash
sudo systemctl stop integrar-plus
sudo systemctl restart integrar-plus
```

### Verificando Status do Servidor

```bash
# Verificar se o Rails está rodando
curl -I http://localhost:3000

# Verificar se o MeiliSearch está rodando
curl -I http://localhost:7700

# Verificar processos ativos
ps aux | grep -E "(rails|puma|meilisearch)"

# Verificar logs em tempo real
tail -f log/production.log
```

## 🎨 Gerenciamento de Assets

### Recarregando Assets

#### 1. Build Completo dos Assets
```bash
# Build de produção
bundle exec rails assets:precompile

# Limpar cache de assets
bundle exec rails assets:clean

# Build + Clean
bundle exec rails assets:clobber assets:precompile
```

#### 2. Recarregar Assets do TailAdmin
```bash
# Configurar assets do TailAdmin
bin/setup-assets
```

#### 3. Build de Produção
```bash
# Build de produção dos assets
bundle exec vite build

# Verificar se build foi criado
ls -la public/assets/
```

### Verificando Assets

```bash
# Verificar se assets estão acessíveis
curl -I http://localhost:3000/assets/application.css
curl -I http://localhost:3000/assets/application.js

# Verificar assets do TailAdmin
curl -I http://localhost:3000/assets/images/logo/logo.svg
curl -I http://localhost:3000/vendor/tailadmin-pro/images/logo/logo.svg
```

## 🔄 Recarregamento Completo do Sistema

### Sequência Recomendada para Atualizações

```bash
# 1. Parar o servidor
pkill -f "puma"

# 2. Atualizar código (se necessário)
git pull origin main

# 3. Instalar dependências
bundle install
npm install

# 4. Executar migrations
source bin/setup-db && bundle exec rails db:migrate:all

# 5. Recarregar assets
bundle exec rails assets:clobber assets:precompile
bundle exec vite build
bin/setup-assets

# 6. Reiniciar servidor
bundle exec rails server -e production -p 3000
```

### Script de Recarregamento Rápido

Use o script `bin/reload-production` para facilitar:

```bash
#!/bin/bash
echo "🔄 Recarregando sistema em produção..."

# Parar servidor
echo "⏹️  Parando servidor..."
pkill -f "puma" 2>/dev/null || echo "Servidor não estava rodando"

# Executar migrations
echo "🗄️  Executando migrations..."
source bin/setup-db && bundle exec rails db:migrate:all

# Recarregar assets
echo "🎨 Recarregando assets..."
bundle exec rails assets:clobber assets:precompile
bundle exec vite build
bin/setup-assets

# Reiniciar servidor
echo "🚀 Reiniciando servidor..."
bundle exec rails server -e production -p 3000
```

Torne executável:
```bash
chmod +x bin/reload-production
```

## 📊 Monitoramento

### Logs do Sistema

```bash
# Logs do Rails (Produção)
tail -f log/production.log

# Logs do servidor (se iniciado com nohup)
tail -f server.log

# Logs do Puma
tail -f log/puma.log

# Logs do MeiliSearch
tail -f storage/meilisearch/meilisearch.log
```

### Verificação de Saúde

```bash
# Verificar uso de memória
free -h

# Verificar uso de disco
df -h

# Verificar processos ativos
ps aux | grep -E "(rails|puma|meilisearch)" | grep -v grep

# Verificar portas em uso
netstat -tlnp | grep -E "(3000|7700)"
```

## 🚨 Troubleshooting

### Problemas Comuns

#### 1. Porta já em uso
```bash
# Verificar qual processo está usando a porta
lsof -i :3000

# Matar o processo
kill -TERM $(lsof -t -i:3000)
```

#### 2. Database não conecta
```bash
# Verificar se PostgreSQL está rodando
sudo systemctl status postgresql

# Reiniciar PostgreSQL
sudo systemctl restart postgresql

# Verificar conexão
source bin/setup-db && bundle exec rails db:version
```

#### 3. Assets não carregam
```bash
# Limpar cache do Rails
bundle exec rails tmp:clear

# Recompilar assets
bundle exec rails assets:clobber assets:precompile

# Verificar permissões
sudo chown -R pedro:pedro public/assets
```

#### 4. MeiliSearch não inicia
```bash
# Verificar se está rodando
curl -I http://localhost:7700

# Reiniciar MeiliSearch
pkill -f meilisearch
meilisearch --http-addr 127.0.0.1:7700 --env development --db-path ./storage/meilisearch --master-key XAXESpKGcHHdauFVvOKlRyWsgMfX0xv513anuJ-_i9w
```

## 📝 Comandos Rápidos

### Aliases Úteis

Adicione ao seu `~/.bashrc`:

```bash
# Aliases para o projeto (Produção)
alias integrar='cd /home/pedro/Documents/integrar/IntegrarPlus'
alias integrar-start='cd /home/pedro/Documents/integrar/IntegrarPlus && bundle exec rails server -e production -p 3000'
alias integrar-migrate='cd /home/pedro/Documents/integrar/IntegrarPlus && source bin/setup-db && bundle exec rails db:migrate:all'
alias integrar-assets='cd /home/pedro/Documents/integrar/IntegrarPlus && bundle exec rails assets:clobber assets:precompile && bundle exec vite build && bin/setup-assets'
alias integrar-reload='cd /home/pedro/Documents/integrar/IntegrarPlus && bin/reload-production'
alias integrar-status='cd /home/pedro/Documents/integrar/IntegrarPlus && bin/status-production'
```

Recarregue o bashrc:
```bash
source ~/.bashrc
```

## 🔐 Segurança

### Firewall

```bash
# Verificar status do firewall
sudo ufw status

# Permitir apenas portas necessárias
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw allow 3000  # Rails (se necessário)
```

### Backup Automático

Crie um script de backup automático:

```bash
#!/bin/bash
# /home/pedro/backup_integrar.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/pedro/backups"
PROJECT_DIR="/home/pedro/Documents/integrar/IntegrarPlus"

mkdir -p $BACKUP_DIR

# Backup do banco
cd $PROJECT_DIR
source bin/setup-db
pg_dump -U pedro integrar_plus_production > $BACKUP_DIR/db_backup_$DATE.sql

# Backup dos uploads
tar -czf $BACKUP_DIR/uploads_backup_$DATE.tar.gz storage/

# Manter apenas os últimos 7 backups
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup concluído: $DATE"
```

Adicione ao crontab para backup diário:
```bash
crontab -e
# Adicionar linha:
0 2 * * * /home/pedro/backup_integrar.sh
```

---

**Última atualização**: Dezembro 2024
**Versão**: 1.0.0
