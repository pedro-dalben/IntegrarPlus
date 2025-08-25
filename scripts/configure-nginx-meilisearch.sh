#!/bin/bash

# Script para configurar Nginx como proxy reverso para Meilisearch
# Uso: sudo ./configure-nginx-meilisearch.sh [dominio]

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para log
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Verificar se está rodando como root
if [[ $EUID -ne 0 ]]; then
   error "Este script deve ser executado como root (sudo)"
fi

# Verificar argumentos
DOMAIN=${1:-"meilisearch.local"}
log "Configurando Nginx para domínio: $DOMAIN"

# Passo 1: Verificar se Nginx está instalado
if ! command -v nginx &> /dev/null; then
    log "Instalando Nginx..."
    apt update
    apt install -y nginx
else
    log "Nginx já está instalado"
fi

# Passo 2: Verificar se Meilisearch está rodando
if ! systemctl is-active --quiet meilisearch; then
    error "Meilisearch não está rodando. Execute primeiro o script de instalação."
fi

# Passo 3: Criar configuração do Nginx
log "Criando configuração do Nginx..."
cat > /etc/nginx/sites-available/meilisearch << EOF
server {
    listen 80;
    server_name $DOMAIN;

    # Logs
    access_log /var/log/nginx/meilisearch_access.log;
    error_log /var/log/nginx/meilisearch_error.log;

    # Configurações de segurança
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Proxy para Meilisearch
    location / {
        proxy_pass http://127.0.0.1:7700;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;

        # Configurações específicas para Meilisearch
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_buffering off;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
        proxy_send_timeout 300s;

        # Configurações de buffer
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;

        # Configurações de cache
        proxy_cache_bypass \$http_upgrade;
        proxy_no_cache \$http_upgrade;
    }

    # Configurações para WebSocket (se necessário)
    location /ws {
        proxy_pass http://127.0.0.1:7700;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Configurações de upload
    client_max_body_size 100M;
    client_body_timeout 300s;
    client_header_timeout 300s;
}
EOF

# Passo 4: Habilitar o site
log "Habilitando site..."
if [[ -L /etc/nginx/sites-enabled/meilisearch ]]; then
    rm /etc/nginx/sites-enabled/meilisearch
fi
ln -s /etc/nginx/sites-available/meilisearch /etc/nginx/sites-enabled/

# Passo 5: Testar configuração
log "Testando configuração do Nginx..."
if nginx -t; then
    log "Configuração do Nginx está válida"
else
    error "Configuração do Nginx inválida"
fi

# Passo 6: Recarregar Nginx
log "Recarregando Nginx..."
systemctl reload nginx

# Passo 7: Configurar SSL (opcional)
read -p "Deseja configurar SSL/HTTPS? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Configurando SSL..."

    # Verificar se certbot está instalado
    if ! command -v certbot &> /dev/null; then
        log "Instalando Certbot..."
        apt install -y certbot python3-certbot-nginx
    fi

    # Obter certificado SSL
    log "Obtendo certificado SSL..."
    certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN

    log "SSL configurado com sucesso!"
fi

# Passo 8: Configurar firewall
log "Configurando firewall..."
ufw allow 'Nginx Full'

# Passo 9: Testar conectividade
log "Testando conectividade..."
sleep 2
if curl -s http://$DOMAIN/health > /dev/null; then
    log "Teste de conectividade: OK"
else
    warn "Teste de conectividade falhou. Verifique se o domínio está resolvendo corretamente."
fi

# Passo 10: Mostrar informações finais
log "Configuração do Nginx concluída!"
echo ""
echo "=== INFORMAÇÕES IMPORTANTES ==="
echo "Domínio configurado: $DOMAIN"
echo "URL do Meilisearch: http://$DOMAIN"
echo "Arquivo de configuração: /etc/nginx/sites-available/meilisearch"
echo "Logs: /var/log/nginx/meilisearch_*.log"
echo ""
echo "=== COMANDOS ÚTEIS ==="
echo "Status do Nginx: systemctl status nginx"
echo "Logs do Nginx: tail -f /var/log/nginx/meilisearch_*.log"
echo "Testar configuração: nginx -t"
echo "Recarregar Nginx: systemctl reload nginx"
echo ""
echo "=== PRÓXIMOS PASSOS ==="
echo "1. Configure o DNS para apontar $DOMAIN para este servidor"
echo "2. Atualize as variáveis de ambiente do Rails:"
echo "   MEILISEARCH_HOST=http://$DOMAIN"
echo "3. Teste a conectividade: curl http://$DOMAIN/health"
echo ""
echo "Para renovar certificado SSL automaticamente:"
echo "crontab -e"
echo "0 12 * * * /usr/bin/certbot renew --quiet"
