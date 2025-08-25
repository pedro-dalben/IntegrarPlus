# Configuração do Meilisearch na VPS Ubuntu

## Visão Geral

Este guia explica como configurar o Meilisearch em uma VPS Ubuntu para o projeto Integrar Plus em ambiente de produção.

## Pré-requisitos

- VPS Ubuntu (recomendado Ubuntu 20.04 LTS ou superior)
- Acesso SSH com privilégios de root ou sudo
- Ruby on Rails já configurado na VPS
- Nginx ou Apache configurado como proxy reverso

## Passo 1: Instalar o Meilisearch

### Conectar via SSH
```bash
ssh usuario@ip-da-vps
```

### Baixar e instalar o Meilisearch
```bash
# Baixar a versão mais recente do Meilisearch
curl -L https://install.meilisearch.com | sh

# Mover para o diretório bin
sudo mv meilisearch /usr/local/bin/

# Verificar instalação
meilisearch --version
```

## Passo 2: Criar usuário e diretórios

### Criar usuário dedicado (opcional mas recomendado)
```bash
# Criar usuário meilisearch
sudo useradd -r -s /bin/false meilisearch

# Criar diretório de dados
sudo mkdir -p /var/lib/meilisearch
sudo chown meilisearch:meilisearch /var/lib/meilisearch
```

### Ou usar o usuário da aplicação
```bash
# Se preferir usar o usuário da aplicação Rails
sudo mkdir -p /var/lib/meilisearch
sudo chown $USER:$USER /var/lib/meilisearch
```

## Passo 3: Configurar o Meilisearch

### Criar arquivo de configuração
```bash
sudo nano /etc/meilisearch.conf
```

### Conteúdo do arquivo de configuração
```toml
# Configuração do Meilisearch para produção
[server]
http_addr = "127.0.0.1:7700"
http_payload_size_limit = "100MB"

[master_key]
# Gerar uma chave mestra segura
key = "SUA_CHAVE_MESTRA_SUPER_SEGURA_AQUI"

[db]
path = "/var/lib/meilisearch/data.ms"

[log]
level = "INFO"
```

### Gerar chave mestra segura
```bash
# Gerar chave aleatória de 32 caracteres
openssl rand -hex 32
```

## Passo 4: Configurar Systemd Service

### Criar arquivo de serviço
```bash
sudo nano /etc/systemd/system/meilisearch.service
```

### Conteúdo do arquivo de serviço
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

### Habilitar e iniciar o serviço
```bash
# Recarregar configurações do systemd
sudo systemctl daemon-reload

# Habilitar serviço para iniciar com o sistema
sudo systemctl enable meilisearch

# Iniciar o serviço
sudo systemctl start meilisearch

# Verificar status
sudo systemctl status meilisearch
```

## Passo 5: Configurar Firewall

### Abrir porta 7700 (se necessário para acesso direto)
```bash
# UFW (Ubuntu)
sudo ufw allow 7700

# Ou iptables
sudo iptables -A INPUT -p tcp --dport 7700 -j ACCEPT
```

## Passo 6: Configurar Nginx como Proxy Reverso

### Criar configuração do Nginx
```bash
sudo nano /etc/nginx/sites-available/meilisearch
```

### Conteúdo da configuração
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

        # Configurações específicas para Meilisearch
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_buffering off;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
}
```

### Habilitar o site
```bash
# Criar link simbólico
sudo ln -s /etc/nginx/sites-available/meilisearch /etc/nginx/sites-enabled/

# Testar configuração
sudo nginx -t

# Recarregar Nginx
sudo systemctl reload nginx
```

## Passo 7: Configurar SSL/HTTPS (Opcional)

### Usando Certbot
```bash
# Instalar Certbot
sudo apt install certbot python3-certbot-nginx

# Obter certificado SSL
sudo certbot --nginx -d meilisearch.seu-dominio.com
```

## Passo 8: Configurar a Aplicação Rails

### Variáveis de ambiente
Adicionar ao arquivo `.env` ou configuração de produção:

```bash
MEILISEARCH_HOST=http://127.0.0.1:7700
MEILISEARCH_API_KEY=SUA_CHAVE_MESTRA_SUPER_SEGURA_AQUI
```

### Ou configurar no Rails
```ruby
# config/environments/production.rb
config.meilisearch = {
  meilisearch_url: ENV.fetch('MEILISEARCH_HOST', 'http://127.0.0.1:7700'),
  meilisearch_api_key: ENV.fetch('MEILISEARCH_API_KEY', 'SUA_CHAVE_MESTRA_SUPER_SEGURA_AQUI')
}
```

## Passo 9: Indexar dados

### Conectar ao servidor e executar
```bash
# Conectar via SSH
ssh usuario@ip-da-vps

# Navegar para o diretório da aplicação
cd /caminho/para/sua/aplicacao

# Indexar todos os dados
RAILS_ENV=production bundle exec rails meilisearch:index
```

## Passo 10: Verificar funcionamento

### Testar conectividade
```bash
# Testar endpoint de saúde
curl http://127.0.0.1:7700/health

# Testar com autenticação
curl -H "Authorization: Bearer SUA_CHAVE_MESTRA_SUPER_SEGURA_AQUI" \
     http://127.0.0.1:7700/version
```

### Verificar logs
```bash
# Ver logs do serviço
sudo journalctl -u meilisearch -f

# Ver logs do Nginx
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## Comandos úteis

### Gerenciar o serviço
```bash
# Iniciar
sudo systemctl start meilisearch

# Parar
sudo systemctl stop meilisearch

# Reiniciar
sudo systemctl restart meilisearch

# Ver status
sudo systemctl status meilisearch

# Ver logs
sudo journalctl -u meilisearch -f
```

### Backup e restauração
```bash
# Backup dos dados
sudo tar -czf meilisearch-backup-$(date +%Y%m%d).tar.gz /var/lib/meilisearch/

# Restaurar dados
sudo systemctl stop meilisearch
sudo tar -xzf meilisearch-backup-YYYYMMDD.tar.gz -C /
sudo systemctl start meilisearch
```

### Monitoramento
```bash
# Ver estatísticas
curl -H "Authorization: Bearer SUA_CHAVE_MESTRA_SUPER_SEGURA_AQUI" \
     http://127.0.0.1:7700/stats

# Ver índices
curl -H "Authorization: Bearer SUA_CHAVE_MESTRA_SUPER_SEGURA_AQUI" \
     http://127.0.0.1:7700/indexes
```

## Solução de problemas

### Erro: "Permission denied"
```bash
# Verificar permissões
sudo chown -R meilisearch:meilisearch /var/lib/meilisearch
sudo chmod -R 755 /var/lib/meilisearch
```

### Erro: "Address already in use"
```bash
# Verificar se há outro processo usando a porta
sudo lsof -i :7700

# Parar processo conflitante
sudo pkill meilisearch
```

### Erro: "Connection refused"
```bash
# Verificar se o serviço está rodando
sudo systemctl status meilisearch

# Verificar firewall
sudo ufw status
```

## Segurança

### Recomendações importantes
1. **Nunca exponha a porta 7700 diretamente** - use sempre proxy reverso
2. **Use uma chave mestra forte** - gere com `openssl rand -hex 32`
3. **Configure firewall** - bloqueie acesso direto à porta 7700
4. **Use HTTPS** - configure SSL para o domínio do Meilisearch
5. **Monitore logs** - configure alertas para tentativas de acesso não autorizado

### Configuração de firewall adicional
```bash
# Bloquear acesso direto à porta 7700 de IPs externos
sudo ufw deny 7700

# Permitir apenas de localhost
sudo ufw allow from 127.0.0.1 to any port 7700
```

## Monitoramento e Manutenção

### Script de monitoramento
```bash
#!/bin/bash
# /usr/local/bin/check-meilisearch.sh

if ! curl -s http://127.0.0.1:7700/health > /dev/null; then
    echo "Meilisearch não está respondendo. Reiniciando..."
    sudo systemctl restart meilisearch
    echo "Meilisearch reiniciado em $(date)" >> /var/log/meilisearch-restart.log
fi
```

### Adicionar ao crontab
```bash
# Verificar a cada 5 minutos
*/5 * * * * /usr/local/bin/check-meilisearch.sh
```

## Conclusão

Com esta configuração, o Meilisearch estará rodando de forma segura e estável na sua VPS Ubuntu, integrado com a aplicação Rails e configurado para produção.
