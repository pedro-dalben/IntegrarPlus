# 🚀 Comandos para VPS - IntegrarPlus

## 📋 Visão Geral

Este documento contém todos os comandos necessários para gerenciar o projeto IntegrarPlus na VPS Ubuntu.

## 🔗 Conexão SSH

```bash
ssh ubuntu1
cd /home/ubuntu/IntegrarPlus
```

## 🗄️ Database e Migrations

### Configurar Ambiente
```bash
# Carregar RVM e configurar variáveis
source ~/.rvm/scripts/rvm
export RAILS_ENV=production
source bin/setup-db
```

### Executar Migrations
```bash
# Todas as migrations pendentes
bundle exec rails db:migrate

# Verificar status das migrations
bundle exec rails db:migrate:status

# Rollback da última migration
bundle exec rails db:rollback

# Reset completo do banco (CUIDADO!)
bundle exec rails db:drop db:create db:migrate db:seed
```

### Executar Seeds
```bash
# Executar seeds para criar dados iniciais
bundle exec rails db:seed

# Executar seeds específicos (se existirem)
bundle exec rails db:seed:replant
```

### Verificar Database
```bash
# Verificar versão do banco
bundle exec rails db:version

# Verificar conexão
bundle exec rails db:console
```

## 🖥️ Gerenciamento do Servidor

### Status do Serviço
```bash
# Verificar status
sudo systemctl status integrarplus.service

# Verificar se está rodando
sudo systemctl is-active integrarplus.service
```

### Controle do Serviço
```bash
# Reiniciar o serviço
sudo systemctl restart integrarplus.service

# Parar o serviço
sudo systemctl stop integrarplus.service

# Iniciar o serviço
sudo systemctl start integrarplus.service

# Habilitar auto-start
sudo systemctl enable integrarplus.service

# Desabilitar auto-start
sudo systemctl disable integrarplus.service
```

### Verificar Processos
```bash
# Ver processos Puma ativos
ps aux | grep puma

# Ver processos na porta 3001
lsof -i :3001

# Ver todos os processos Rails
ps aux | grep -E "(rails|puma|ruby)"
```

## 📝 Logs e Monitoramento

### Logs do Serviço
```bash
# Ver logs em tempo real
sudo journalctl -u integrarplus.service -f

# Ver logs recentes (últimas 50 linhas)
sudo journalctl -u integrarplus.service -n 50

# Ver logs das últimas 24h
sudo journalctl -u integrarplus.service --since "24 hours ago"

# Ver logs de hoje
sudo journalctl -u integrarplus.service --since today
```

### Filtros de Logs
```bash
# Ver apenas requisições
sudo journalctl -u integrarplus.service -f | grep -E "(Started|Completed)"

# Ver apenas erros
sudo journalctl -u integrarplus.service -f | grep ERROR

# Ver apenas erros de rota
sudo journalctl -u integrarplus.service -f | grep "ActionController::RoutingError"

# Ver logs de um IP específico
sudo journalctl -u integrarplus.service -f | grep "127.0.0.1"
```

### Logs de Arquivo (se existirem)
```bash
# Ver logs do Rails
tail -f log/production.log

# Ver logs de desenvolvimento
tail -f log/development.log

# Ver logs do Puma
tail -f log/puma.log
```

## 🎨 Assets e Build

### Recarregar Assets
```bash
# Build completo dos assets
bundle exec rails assets:clobber assets:precompile

# Build do Vite
bundle exec vite build

# Configurar assets do TailAdmin
bin/setup-assets

# Verificar assets
ls -la public/assets/
```

### Verificar Assets
```bash
# Verificar se assets estão acessíveis
curl -I http://localhost:3001/assets/application.css
curl -I http://localhost:3001/assets/application.js

# Verificar assets do TailAdmin
curl -I http://localhost:3001/assets/images/logo/logo.svg
```

## 🔄 Recarregamento Completo

### Sequência Completa de Atualização
```bash
# 1. Parar o serviço
sudo systemctl stop integrarplus.service

# 2. Executar migrations
source ~/.rvm/scripts/rvm
export RAILS_ENV=production
source bin/setup-db
bundle exec rails db:migrate

# 3. Executar seeds (se necessário)
bundle exec rails db:seed

# 4. Recarregar assets
bundle exec rails assets:clobber assets:precompile
bundle exec vite build
bin/setup-assets

# 5. Reiniciar o serviço
sudo systemctl start integrarplus.service

# 6. Verificar status
sudo systemctl status integrarplus.service
```

### Script Rápido de Recarregamento
```bash
# Usar o script atualizado
bin/reload-vps
```

**O que o script faz:**
1. ⏹️ Para o serviço
2. 📥 Atualiza código (`git pull origin master`)
3. ⚙️ Configura ambiente
4. 🗄️ Executa migrations
5. 🎨 Recarrega assets
6. 🔍 Reindexa MeiliSearch
7. 🚀 Reinicia serviço
8. ✅ Verifica status

## 🛠️ Tarefas Específicas

### Importador de Documentos
```bash
# Executar importador
bundle exec rake documents:import_from_csv

# Verificar logs do importador
ls -la storage/importador/
cat storage/importador/import_log_*.txt
```

### MeiliSearch
```bash
# Reindexar todos os modelos
bundle exec rails meilisearch:reindex

# Limpar todos os índices
bundle exec rails meilisearch:clear

# Reset completo (limpar + reindexar)
bundle exec rails meilisearch:reset

# Indexar todos os dados
bundle exec rails meilisearch:index

# Verificar status do MeiliSearch
curl -I http://localhost:7700

# Ver tasks disponíveis
bundle exec rails -T | grep meili
```

### Backup do Banco
```bash
# Backup do banco
pg_dump -U pedro integrar_plus_production > backup_$(date +%Y%m%d_%H%M%S).sql

# Restaurar backup
psql -U pedro integrar_plus_production < backup_file.sql
```

### Verificar Dependências
```bash
# Verificar gems
bundle check

# Instalar gems
bundle install

# Verificar Node.js
npm list

# Instalar dependências Node.js
npm install
```

## 🔍 Troubleshooting

### Problemas Comuns

#### 1. Serviço não inicia
```bash
# Verificar logs de erro
sudo journalctl -u integrarplus.service -n 100

# Verificar configuração
sudo cat /etc/systemd/system/integrarplus.service

# Testar manualmente
source ~/.rvm/scripts/rvm
export RAILS_ENV=production
source bin/setup-db
bundle exec rails server -e production -p 3001
```

#### 2. Porta já em uso
```bash
# Verificar qual processo está usando a porta
lsof -i :3001

# Matar processo
sudo kill -TERM $(lsof -t -i:3001)

# Reiniciar serviço
sudo systemctl restart integrarplus.service
```

#### 3. Database não conecta
```bash
# Verificar PostgreSQL
sudo systemctl status postgresql

# Reiniciar PostgreSQL
sudo systemctl restart postgresql

# Testar conexão
bundle exec rails db:version
```

#### 4. Assets não carregam
```bash
# Limpar cache
bundle exec rails tmp:clear

# Recompilar assets
bundle exec rails assets:clobber assets:precompile

# Verificar permissões
sudo chown -R ubuntu:ubuntu public/assets
```

#### 5. Busca MeiliSearch não funciona
```bash
# Verificar se MeiliSearch está rodando
curl -I http://localhost:7700

# Reindexar dados
bundle exec rails meilisearch:reindex

# Verificar configuração
bundle exec rails runner 'puts MeiliSearch::Rails.configuration'

# Testar busca via Rails
bundle exec rails runner 'puts Document.search("teste").count'
```

## 📊 Monitoramento

### Verificar Recursos
```bash
# Uso de memória
free -h

# Uso de disco
df -h

# Uso de CPU
top

# Processos ativos
ps aux | grep -E "(rails|puma|meilisearch)" | grep -v grep
```

### Testar Aplicação
```bash
# Testar resposta HTTP
curl -I http://localhost:3001

# Testar com dados
curl -s http://localhost:3001 | head -20

# Testar performance
ab -n 100 -c 10 http://localhost:3001/
```

## 🚀 Comandos Rápidos

### Aliases Úteis (adicionar ao ~/.bashrc)
```bash
# Aliases para o projeto
alias integrar='cd /home/ubuntu/IntegrarPlus'
alias integrar-status='sudo systemctl status integrarplus.service'
alias integrar-restart='sudo systemctl restart integrarplus.service'
alias integrar-logs='sudo journalctl -u integrarplus.service -f'
alias integrar-migrate='cd /home/ubuntu/IntegrarPlus && source ~/.rvm/scripts/rvm && export RAILS_ENV=production && source bin/setup-db && bundle exec rails db:migrate'
alias integrar-seed='cd /home/ubuntu/IntegrarPlus && source ~/.rvm/scripts/rvm && export RAILS_ENV=production && source bin/setup-db && bundle exec rails db:seed'
alias integrar-assets='cd /home/ubuntu/IntegrarPlus && source ~/.rvm/scripts/rvm && export RAILS_ENV=production && bundle exec rails assets:clobber assets:precompile && bundle exec vite build && bin/setup-assets'
alias integrar-reindex='cd /home/ubuntu/IntegrarPlus && source ~/.rvm/scripts/rvm && export RAILS_ENV=production && source bin/setup-db && bundle exec rails meilisearch:reindex'
```

### Recarregar aliases
```bash
source ~/.bashrc
```

## 📱 URLs de Acesso

- **Aplicação**: http://localhost:3001
- **MeiliSearch**: http://localhost:7700
- **Logs**: `sudo journalctl -u integrarplus.service -f`

---

**Última atualização**: Dezembro 2024
**Versão**: 1.0.0
