# Configuração do Meilisearch na VPS - Guia Rápido

## Visão Geral

Este guia fornece instruções rápidas para configurar o Meilisearch em uma VPS Ubuntu para o projeto Integrar Plus.

## Pré-requisitos

- VPS Ubuntu 20.04 LTS ou superior
- Acesso SSH com privilégios de root
- Ruby on Rails configurado na VPS

## Instalação Rápida

### 1. Conectar via SSH
```bash
ssh usuario@ip-da-vps
```

### 2. Baixar e executar script de instalação
```bash
# Baixar o script do projeto
wget https://raw.githubusercontent.com/seu-repo/IntegrarPlus/main/scripts/install-meilisearch-vps.sh

# Tornar executável
chmod +x install-meilisearch-vps.sh

# Executar instalação
sudo ./install-meilisearch-vps.sh
```

### 3. Configurar Nginx (opcional)
```bash
# Baixar script de configuração do Nginx
wget https://raw.githubusercontent.com/seu-repo/IntegrarPlus/main/scripts/configure-nginx-meilisearch.sh

# Tornar executável
chmod +x configure-nginx-meilisearch.sh

# Configurar Nginx
sudo ./configure-nginx-meilisearch.sh seu-dominio.com
```

## Configuração Manual

### Passo 1: Instalar Meilisearch
```bash
# Baixar e instalar
curl -L https://install.meilisearch.com | sh
sudo mv meilisearch /usr/local/bin/
```

### Passo 2: Criar usuário e diretórios
```bash
sudo useradd -r -s /bin/false meilisearch
sudo mkdir -p /var/lib/meilisearch
sudo chown meilisearch:meilisearch /var/lib/meilisearch
```

### Passo 3: Gerar chave mestra
```bash
MASTER_KEY=$(openssl rand -hex 32)
echo "Chave mestra: $MASTER_KEY"
```

### Passo 4: Criar arquivo de configuração
```bash
sudo nano /etc/meilisearch.conf
```

Conteúdo:
```toml
[server]
http_addr = "127.0.0.1:7700"
http_payload_size_limit = "100MB"

[master_key]
key = "SUA_CHAVE_MESTRA_AQUI"

[db]
path = "/var/lib/meilisearch/data.ms"

[log]
level = "INFO"
```

### Passo 5: Criar serviço systemd
```bash
sudo nano /etc/systemd/system/meilisearch.service
```

Conteúdo:
```ini
[Unit]
Description=Meilisearch
After=network.target

[Service]
Type=simple
User=meilisearch
Group=meilisearch
ExecStart=/usr/local/bin/meilisearch --config-file-path /etc/meilisearch.conf
Restart=always
RestartSec=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

### Passo 6: Iniciar serviço
```bash
sudo systemctl daemon-reload
sudo systemctl enable meilisearch
sudo systemctl start meilisearch
```

## Configuração do Rails

### Variáveis de ambiente
Adicione ao arquivo `.env` ou configuração de produção:

```bash
MEILISEARCH_HOST=http://127.0.0.1:7700
MEILISEARCH_API_KEY=SUA_CHAVE_MESTRA_AQUI
```

### Ou configurar no Rails
```ruby
# config/environments/production.rb
config.meilisearch = {
  meilisearch_url: ENV.fetch('MEILISEARCH_HOST', 'http://127.0.0.1:7700'),
  meilisearch_api_key: ENV.fetch('MEILISEARCH_API_KEY', 'SUA_CHAVE_MESTRA_AQUI')
}
```

## Indexar dados

```bash
# Conectar ao servidor
ssh usuario@ip-da-vps

# Navegar para o diretório da aplicação
cd /caminho/para/sua/aplicacao

# Indexar todos os dados
RAILS_ENV=production bundle exec rails meilisearch:index
```

## Verificação

### Script de verificação
```bash
# Baixar script de verificação
wget https://raw.githubusercontent.com/seu-repo/IntegrarPlus/main/scripts/check-meilisearch-status.sh

# Tornar executável
chmod +x check-meilisearch-status.sh

# Executar verificação
./check-meilisearch-status.sh
```

### Verificação manual
```bash
# Testar conectividade
curl http://127.0.0.1:7700/health

# Verificar status do serviço
sudo systemctl status meilisearch

# Ver logs
sudo journalctl -u meilisearch -f
```

## Comandos úteis

### Gerenciar serviço
```bash
# Status
sudo systemctl status meilisearch

# Iniciar
sudo systemctl start meilisearch

# Parar
sudo systemctl stop meilisearch

# Reiniciar
sudo systemctl restart meilisearch

# Logs
sudo journalctl -u meilisearch -f
```

### Backup e restauração
```bash
# Backup
sudo tar -czf meilisearch-backup-$(date +%Y%m%d).tar.gz /var/lib/meilisearch/

# Restaurar
sudo systemctl stop meilisearch
sudo tar -xzf meilisearch-backup-YYYYMMDD.tar.gz -C /
sudo systemctl start meilisearch
```

## Configuração de Nginx

### Arquivo de configuração
```bash
sudo nano /etc/nginx/sites-available/meilisearch
```

Conteúdo:
```nginx
server {
    listen 80;
    server_name meilisearch.seu-dominio.com;

    location / {
        proxy_pass http://127.0.0.1:7700;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_buffering off;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
}
```

### Habilitar site
```bash
sudo ln -s /etc/nginx/sites-available/meilisearch /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## SSL/HTTPS

### Usando Certbot
```bash
# Instalar Certbot
sudo apt install certbot python3-certbot-nginx

# Obter certificado
sudo certbot --nginx -d meilisearch.seu-dominio.com
```

## Monitoramento

### Script de monitoramento automático
```bash
# Criar script
sudo nano /usr/local/bin/check-meilisearch.sh
```

Conteúdo:
```bash
#!/bin/bash
if ! curl -s http://127.0.0.1:7700/health > /dev/null; then
    echo "Meilisearch não está respondendo. Reiniciando..."
    sudo systemctl restart meilisearch
    echo "Meilisearch reiniciado em $(date)" >> /var/log/meilisearch-restart.log
fi
```

### Adicionar ao crontab
```bash
sudo crontab -e
# Adicionar linha:
*/5 * * * * /usr/local/bin/check-meilisearch.sh
```

## Solução de problemas

### Erro: "Address already in use"
```bash
sudo lsof -i :7700
sudo pkill meilisearch
```

### Erro: "Permission denied"
```bash
sudo chown -R meilisearch:meilisearch /var/lib/meilisearch
sudo chmod -R 755 /var/lib/meilisearch
```

### Erro: "Connection refused"
```bash
sudo systemctl status meilisearch
sudo journalctl -u meilisearch -f
```

## Segurança

### Firewall
```bash
# Bloquear acesso direto à porta 7700
sudo ufw deny 7700

# Permitir apenas de localhost
sudo ufw allow from 127.0.0.1 to any port 7700
```

### Recomendações
1. Use sempre proxy reverso (Nginx/Apache)
2. Configure SSL/HTTPS
3. Use chave mestra forte
4. Monitore logs regularmente
5. Faça backups periódicos

## Recursos adicionais

- [Documentação oficial do Meilisearch](https://docs.meilisearch.com/)
- [Guia completo de configuração](docs/MEILISEARCH_VPS_SETUP.md)
- [Configuração local](docs/MEILISEARCH_SETUP.md)
