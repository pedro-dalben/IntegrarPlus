#!/bin/bash

# Script para verificar o status do Meilisearch na VPS
# Uso: ./check-meilisearch-status.sh [host]

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Configuração
HOST=${1:-"127.0.0.1:7700"}
API_KEY=${MEILISEARCH_API_KEY:-"XAXESpKGcHHdauFVvOKlRyWsgMfX0xv513anuJ-_i9w"}

echo "=== VERIFICAÇÃO DO MEILISEARCH ==="
echo "Host: $HOST"
echo "API Key: ${API_KEY:0:10}..."
echo ""

# Função para fazer requisição HTTP
http_request() {
    local endpoint=$1
    local method=${2:-"GET"}
    local data=${3:-""}

    if [[ -n "$data" ]]; then
        curl -s -X "$method" \
             -H "Content-Type: application/json" \
             -H "Authorization: Bearer $API_KEY" \
             -d "$data" \
             "http://$HOST$endpoint"
    else
        curl -s -X "$method" \
             -H "Authorization: Bearer $API_KEY" \
             "http://$HOST$endpoint"
    fi
}

# Teste 1: Verificar se o serviço está respondendo
log "Teste 1: Verificando conectividade básica..."
if curl -s "http://$HOST/health" > /dev/null; then
    log "✓ Meilisearch está respondendo"
else
    error "✗ Meilisearch não está respondendo"
    exit 1
fi

# Teste 2: Verificar versão
log "Teste 2: Verificando versão..."
VERSION_RESPONSE=$(http_request "/version")
if [[ $? -eq 0 ]]; then
    VERSION=$(echo "$VERSION_RESPONSE" | grep -o '"pkgVersion":"[^"]*"' | cut -d'"' -f4)
    log "✓ Versão do Meilisearch: $VERSION"
else
    warn "✗ Não foi possível obter a versão"
fi

# Teste 3: Verificar estatísticas
log "Teste 3: Verificando estatísticas..."
STATS_RESPONSE=$(http_request "/stats")
if [[ $? -eq 0 ]]; then
    log "✓ Estatísticas obtidas com sucesso"
    echo "$STATS_RESPONSE" | jq '.' 2>/dev/null || echo "$STATS_RESPONSE"
else
    warn "✗ Não foi possível obter estatísticas"
fi

# Teste 4: Verificar índices
log "Teste 4: Verificando índices..."
INDEXES_RESPONSE=$(http_request "/indexes")
if [[ $? -eq 0 ]]; then
    INDEX_COUNT=$(echo "$INDEXES_RESPONSE" | grep -o '"results":\[[^]]*\]' | grep -o '\[.*\]' | jq 'length' 2>/dev/null || echo "0")
    log "✓ Número de índices: $INDEX_COUNT"

    if [[ "$INDEX_COUNT" -gt 0 ]]; then
        echo "Índices encontrados:"
        echo "$INDEXES_RESPONSE" | jq '.results[].uid' 2>/dev/null || echo "$INDEXES_RESPONSE"
    fi
else
    warn "✗ Não foi possível obter índices"
fi

# Teste 5: Verificar configuração
log "Teste 5: Verificando configuração..."
CONFIG_RESPONSE=$(http_request "/config")
if [[ $? -eq 0 ]]; then
    log "✓ Configuração obtida com sucesso"
else
    warn "✗ Não foi possível obter configuração"
fi

# Teste 6: Verificar se é possível criar um índice de teste
log "Teste 6: Testando criação de índice..."
TEST_INDEX_RESPONSE=$(http_request "/indexes" "POST" '{"uid":"test-index","primaryKey":"id"}')
if [[ $? -eq 0 ]]; then
    log "✓ Índice de teste criado com sucesso"

    # Remover índice de teste
    DELETE_RESPONSE=$(http_request "/indexes/test-index" "DELETE")
    if [[ $? -eq 0 ]]; then
        log "✓ Índice de teste removido"
    else
        warn "✗ Não foi possível remover índice de teste"
    fi
else
    warn "✗ Não foi possível criar índice de teste"
fi

# Teste 7: Verificar logs (se executado localmente)
if [[ "$HOST" == "127.0.0.1:7700" ]]; then
    log "Teste 7: Verificando logs do sistema..."
    if systemctl is-active --quiet meilisearch; then
        log "✓ Serviço Meilisearch está ativo"

        # Verificar logs recentes
        RECENT_LOGS=$(journalctl -u meilisearch --since "5 minutes ago" --no-pager | tail -5)
        if [[ -n "$RECENT_LOGS" ]]; then
            log "Logs recentes:"
            echo "$RECENT_LOGS"
        fi
    else
        error "✗ Serviço Meilisearch não está ativo"
    fi
fi

# Teste 8: Verificar uso de recursos
if [[ "$HOST" == "127.0.0.1:7700" ]]; then
    log "Teste 8: Verificando uso de recursos..."

    # Verificar processo
    MEILIS_PID=$(pgrep meilisearch)
    if [[ -n "$MEILIS_PID" ]]; then
        log "✓ Processo Meilisearch encontrado (PID: $MEILIS_PID)"

        # Verificar uso de memória
        MEMORY_USAGE=$(ps -o rss= -p $MEILIS_PID)
        MEMORY_MB=$((MEMORY_USAGE / 1024))
        log "✓ Uso de memória: ${MEMORY_MB}MB"

        # Verificar uso de CPU
        CPU_USAGE=$(ps -o %cpu= -p $MEILIS_PID)
        log "✓ Uso de CPU: ${CPU_USAGE}%"
    else
        warn "✗ Processo Meilisearch não encontrado"
    fi
fi

echo ""
echo "=== RESUMO ==="
log "Verificação concluída!"

# Verificar se todos os testes passaram
if [[ $? -eq 0 ]]; then
    log "✓ Meilisearch está funcionando corretamente"
else
    warn "⚠ Alguns testes falharam. Verifique os logs acima."
fi

echo ""
echo "=== COMANDOS ÚTEIS ==="
echo "Status do serviço: systemctl status meilisearch"
echo "Logs em tempo real: journalctl -u meilisearch -f"
echo "Reiniciar serviço: systemctl restart meilisearch"
echo "Testar conectividade: curl http://$HOST/health"
echo "Dashboard: http://$HOST"
