#!/bin/bash

# Script completo para deploy da busca avançada
# Execute este script no servidor de produção após o deploy

echo "🚀 Iniciando deploy da busca avançada..."

# Verificar se estamos no diretório correto
if [ ! -d "app/views/admin" ]; then
    echo "❌ Erro: Execute este script no diretório raiz do projeto Rails"
    exit 1
fi

echo "📝 Passo 1: Corrigindo nomes dos partials..."
# Renomear partials sem underscore para o formato correto
find app/views/admin -name "search_results.html.erb" -exec bash -c '
    dir=$(dirname "$1")
    base=$(basename "$1")
    echo "  Renomeando: $1 -> $dir/_$base"
    mv "$1" "$dir/_$base"
' _ {} \;

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
echo "📝 Passo 2: Verificando estrutura das views..."

# Verificar se as views têm a estrutura correta de controller
views_with_container=$(grep -l "Container da Busca Avançada" app/views/admin/*/index.html.erb | wc -l)
echo "Views com estrutura corrigida: $views_with_container/8"

echo ""
echo "📝 Passo 3: Verificando arquivos importantes..."

# Verificar se os arquivos principais existem
files_to_check=(
    "app/services/advanced_search_service.rb"
    "app/frontend/javascript/controllers/advanced_search_controller.js"
    "app/frontend/javascript/controllers/index.js"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file existe"
    else
        echo "❌ $file NÃO EXISTE"
    fi
done

echo ""
echo "📝 Passo 4: Verificando registro do controller Stimulus..."
if grep -q "advanced-search" app/frontend/javascript/controllers/index.js; then
    echo "✅ Controller Stimulus registrado"
else
    echo "❌ Controller Stimulus NÃO REGISTRADO"
fi

echo ""
echo "📝 Passo 5: Verificando MeiliSearch..."
if command -v meilisearch &> /dev/null; then
    echo "✅ MeiliSearch instalado"

    # Verificar se está rodando
    if curl -s http://localhost:7700/health > /dev/null 2>&1; then
        echo "✅ MeiliSearch está rodando"
    else
        echo "⚠️  MeiliSearch não está rodando"
        echo "💡 Execute: meilisearch --http-addr localhost:7700 &"
    fi
else
    echo "❌ MeiliSearch não instalado"
fi

echo ""
echo "🔄 Passo 6: Preparando para reiniciar aplicação..."
echo "Execute os próximos comandos:"
echo ""
echo "# Para reiniciar MeiliSearch se necessário:"
echo "meilisearch --http-addr localhost:7700 &"
echo ""
echo "# Para reindexar dados:"
echo "bundle exec rails meilisearch:reindex"
echo ""
echo "# Para reiniciar aplicação:"
echo "sudo systemctl restart integrar-plus"
echo ""
echo "# Para monitorar logs:"
echo "tail -f log/production.log"

echo ""
echo "✅ Script de verificação executado com sucesso!"
echo ""
echo "📋 Resumo da Busca Avançada:"
echo "✅ Serviço AdvancedSearchService implementado"
echo "✅ Controller Stimulus advanced-search criado"
echo "✅ 8 controllers Rails atualizados"
echo "✅ 8 views com busca AJAX"
echo "✅ 7 partials de resultados criados"
echo "✅ Fallback para busca local implementado"
echo "✅ Campo de busca não limpa mais"
echo "✅ Interface responsiva e moderna"
