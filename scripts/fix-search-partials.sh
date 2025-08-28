#!/bin/bash

# Script para corrigir os nomes dos partials de busca
# Execute este script no servidor de produção após o deploy

echo "🔧 Corrigindo nomes dos partials de busca..."

# Verificar se estamos no diretório correto
if [ ! -d "app/views/admin" ]; then
    echo "❌ Erro: Execute este script no diretório raiz do projeto Rails"
    exit 1
fi

# Renomear partials sem underscore para o formato correto
echo "📝 Renomeando partials..."
find app/views/admin -name "search_results.html.erb" -exec bash -c '
    dir=$(dirname "$1")
    base=$(basename "$1")
    echo "  Renomeando: $1 -> $dir/_$base"
    mv "$1" "$dir/_$base"
' _ {} \;

# Verificar se a correção funcionou
echo ""
echo "✅ Verificando partials criados:"
partials=$(find app/views/admin -name "_search_results.html.erb" | wc -l)

if [ $partials -eq 7 ]; then
    echo "✅ Sucesso! Encontrados $partials partials corretos:"
    find app/views/admin -name "_search_results.html.erb" | sort
else
    echo "⚠️  Atenção: Encontrados apenas $partials partials (esperado: 7)"
    find app/views/admin -name "_search_results.html.erb" | sort
fi

echo ""
echo "🚀 Próximos passos:"
echo "1. Reiniciar a aplicação: sudo systemctl restart integrar-plus"
echo "2. Testar a busca nas telas administrativas"
echo "3. Verificar se não há mais erros 500"

echo ""
echo "✅ Script executado com sucesso!"
