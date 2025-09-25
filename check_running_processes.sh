#!/bin/bash

echo "=== VERIFICANDO PROCESSOS EM EXECUÇÃO ==="

echo "1. Verificando processos Ruby/Rails..."
ps aux | grep -E "(ruby|rails|puma|sidekiq)" | grep -v grep

echo ""
echo "2. Verificando portas em uso..."
netstat -tlnp | grep -E ":(3000|8080|80|443)" || echo "Nenhuma porta Rails encontrada"

echo ""
echo "3. Verificando arquivos de PID..."
if [ -f "tmp/pids/server.pid" ]; then
    echo "PID do servidor: $(cat tmp/pids/server.pid)"
    echo "Processo ainda rodando: $(ps -p $(cat tmp/pids/server.pid) 2>/dev/null || echo 'Não encontrado')"
else
    echo "Nenhum arquivo PID encontrado"
fi

echo ""
echo "4. Verificando processos que podem estar usando cache antigo..."
lsof +D tmp/cache 2>/dev/null || echo "Nenhum processo usando cache"

echo ""
echo "5. Verificando memória compartilhada..."
ipcs -m 2>/dev/null || echo "Nenhuma memória compartilhada"

echo ""
echo "=== RECOMENDAÇÕES ==="
echo "Se houver processos Ruby/Rails rodando:"
echo "1. Execute: sudo pkill -f ruby"
echo "2. Execute: sudo pkill -f puma"
echo "3. Execute: sudo pkill -f sidekiq"
echo "4. Depois execute: ./aggressive_cache_clear.sh"

echo ""
echo "=== VERIFICAÇÃO CONCLUÍDA ==="
