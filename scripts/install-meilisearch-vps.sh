#!/bin/bash

# Script de instalação do Meilisearch para VPS Ubuntu
# Uso: sudo ./install-meilisearch-vps.sh

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

# Verificar sistema operacional
if [[ ! -f /etc/os-release ]]; then
    error "Não foi possível detectar o sistema operacional"
fi

source /etc/os-release
if [[ "$ID" != "ubuntu" ]]; then
    warn "Este script foi testado apenas no Ubuntu. Continue com cuidado."
fi

log "Iniciando instalação do Meilisearch..."

# Passo 1: Atualizar sistema
log "Atualizando sistema..."
apt update && apt upgrade -y

# Passo 2: Instalar dependências
log "Instalando dependências..."
apt install -y curl wget nano ufw

# Passo 3: Baixar e instalar Meilisearch
log "Baixando Meilisearch..."
curl -L https://install.meilisearch.com | sh

if [[ -f "meilisearch" ]]; then
    mv meilisearch /usr/local/bin/
    chmod +x /usr/local/bin/meilisearch
    log "Meilisearch instalado em /usr/local/bin/meilisearch"
else
    error "Falha ao baixar Meilisearch"
fi

# Passo 4: Criar usuário e diretórios
log "Criando usuário e diretórios..."
useradd -r -s /bin/false meilisearch || true
mkdir -p /var/lib/meilisearch
chown meilisearch:meilisearch /var/lib/meilisearch

# Passo 5: Gerar chave mestra
log "Gerando chave mestra..."
MASTER_KEY=$(openssl rand -hex 32)
log "Chave mestra gerada: $MASTER_KEY"

# Passo 6: Criar arquivo de configuração
log "Criando arquivo de configuração..."
cat > /etc/meilisearch.conf << EOF
[server]
http_addr = "127.0.0.1:7700"
http_payload_size_limit = "100MB"

[master_key]
key = "$MASTER_KEY"

[db]
path = "/var/lib/meilisearch/data.ms"

[log]
level = "INFO"
EOF

chown meilisearch:meilisearch /etc/meilisearch.conf
chmod 600 /etc/meilisearch.conf

# Passo 7: Criar serviço systemd
log "Criando serviço systemd..."
cat > /etc/systemd/system/meilisearch.service << EOF
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
EOF

# Passo 8: Habilitar e iniciar serviço
log "Habilitando e iniciando serviço..."
systemctl daemon-reload
systemctl enable meilisearch
systemctl start meilisearch

# Passo 9: Verificar se está rodando
log "Verificando status do serviço..."
sleep 3
if systemctl is-active --quiet meilisearch; then
    log "Meilisearch está rodando com sucesso!"
else
    error "Falha ao iniciar Meilisearch"
fi

# Passo 10: Configurar firewall
log "Configurando firewall..."
ufw --force enable
ufw allow ssh
ufw allow 80
ufw allow 443
ufw deny 7700  # Bloquear acesso direto à porta 7700

# Passo 11: Testar conectividade
log "Testando conectividade..."
if curl -s http://127.0.0.1:7700/health > /dev/null; then
    log "Teste de conectividade: OK"
else
    warn "Teste de conectividade falhou. Verifique os logs."
fi

# Passo 12: Criar script de monitoramento
log "Criando script de monitoramento..."
cat > /usr/local/bin/check-meilisearch.sh << 'EOF'
#!/bin/bash
if ! curl -s http://127.0.0.1:7700/health > /dev/null; then
    echo "Meilisearch não está respondendo. Reiniciando..."
    systemctl restart meilisearch
    echo "Meilisearch reiniciado em $(date)" >> /var/log/meilisearch-restart.log
fi
EOF

chmod +x /usr/local/bin/check-meilisearch.sh

# Passo 13: Criar arquivo de configuração para Rails
log "Criando arquivo de configuração para Rails..."
cat > /tmp/meilisearch-rails-config.txt << EOF
# Adicione estas variáveis de ambiente ao seu arquivo .env ou configuração de produção:

MEILISEARCH_HOST=http://127.0.0.1:7700
MEILISEARCH_API_KEY=$MASTER_KEY

# Ou configure no Rails (config/environments/production.rb):
config.meilisearch = {
  meilisearch_url: ENV.fetch('MEILISEARCH_HOST', 'http://127.0.0.1:7700'),
  meilisearch_api_key: ENV.fetch('MEILISEARCH_API_KEY', '$MASTER_KEY')
}
EOF

# Passo 14: Mostrar informações finais
log "Instalação concluída com sucesso!"
echo ""
echo "=== INFORMAÇÕES IMPORTANTES ==="
echo "Chave mestra: $MASTER_KEY"
echo "Porta: 7700 (apenas localhost)"
echo "Diretório de dados: /var/lib/meilisearch"
echo "Arquivo de configuração: /etc/meilisearch.conf"
echo ""
echo "=== COMANDOS ÚTEIS ==="
echo "Status: systemctl status meilisearch"
echo "Logs: journalctl -u meilisearch -f"
echo "Reiniciar: systemctl restart meilisearch"
echo "Parar: systemctl stop meilisearch"
echo ""
echo "=== CONFIGURAÇÃO RAILS ==="
echo "Verifique o arquivo: /tmp/meilisearch-rails-config.txt"
echo ""
echo "=== PRÓXIMOS PASSOS ==="
echo "1. Configure o Nginx como proxy reverso"
echo "2. Configure SSL/HTTPS"
echo "3. Adicione as variáveis de ambiente ao Rails"
echo "4. Execute: RAILS_ENV=production bundle exec rails meilisearch:index"
echo ""
echo "Para monitoramento automático, adicione ao crontab:"
echo "*/5 * * * * /usr/local/bin/check-meilisearch.sh"
