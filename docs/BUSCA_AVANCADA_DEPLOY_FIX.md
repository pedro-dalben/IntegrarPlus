# Fix para Deploy - Busca Avançada

## 🚨 Problemas Identificados e Corrigidos

### 1. Partials sem Underscore
O erro no ambiente de produção ocorria porque os partials não estavam nomeados corretamente:

```
ActionView::MissingTemplate (Missing partial admin/workspace/_search_results
```

### 2. Targets Fora do Escopo do Controller
O JavaScript estava fazendo reload da página porque os targets `results` estavam fora do elemento que contém o controller Stimulus.

## ✅ Solução Aplicada

### 1. Renomeação dos Partials

Os arquivos foram renomeados para seguir a convenção Rails de partials (com underscore):

```bash
# ANTES (incorreto)
app/views/admin/workspace/search_results.html.erb
app/views/admin/documents/search_results.html.erb
# ... outros

# DEPOIS (correto)
app/views/admin/workspace/_search_results.html.erb
app/views/admin/documents/_search_results.html.erb
# ... outros
```

### 2. Reestruturação das Views
As views foram corrigidas para incluir os targets dentro do escopo do controller:

```erb
<!-- ANTES (incorreto) -->
<div data-controller="advanced-search">
  <!-- campo de busca -->
</div>
<div data-advanced-search-target="results"> <!-- FORA DO ESCOPO -->

<!-- DEPOIS (correto) -->
<div data-controller="advanced-search">
  <!-- campo de busca -->
  <div data-advanced-search-target="results"> <!-- DENTRO DO ESCOPO -->
  </div>
</div>
```

### 3. Comando para Aplicar no VPS

Execute este comando no servidor de produção:

```bash
cd /home/ubuntu/IntegrarPlus

# Usar o script completo de deploy
./scripts/deploy-advanced-search.sh
```

Ou manualmente:

```bash
# Renomear todos os partials para o formato correto
find app/views/admin -name "search_results.html.erb" -exec bash -c 'dir=$(dirname "$1"); base=$(basename "$1"); mv "$1" "$dir/_$base"' _ {} \;

# Verificar se funcionou
find app/views/admin -name "_search_results.html.erb"
```

### 3. Verificação

Deve retornar 7 arquivos:
- `app/views/admin/workspace/_search_results.html.erb`
- `app/views/admin/documents/_search_results.html.erb`
- `app/views/admin/professionals/_search_results.html.erb`
- `app/views/admin/groups/_search_results.html.erb`
- `app/views/admin/specialities/_search_results.html.erb`
- `app/views/admin/specializations/_search_results.html.erb`
- `app/views/admin/contract_types/_search_results.html.erb`

### 4. Restart da Aplicação

```bash
# Reiniciar a aplicação
sudo systemctl restart integrar-plus
```

## 🎯 Status da Busca Avançada

✅ **Todos os controllers corrigidos** - respondem corretamente às requisições AJAX
✅ **Todos os partials criados** - com nomes corretos
✅ **JavaScript funcionando** - campo de busca não limpa mais
✅ **Fallback implementado** - funciona mesmo offline
✅ **MeiliSearch integrado** - busca otimizada

## 📋 Como Testar no Ambiente de Produção

1. Acesse qualquer tela com busca (ex: Workspace, Profissionais)
2. Digite no campo de busca
3. Verifique se:
   - O campo não limpa após a busca
   - Os resultados aparecem dinamicamente
   - É possível fazer múltiplas buscas seguidas
   - Não há mais erros 500

## 🔍 Debug

Se ainda houver erros, verifique:

```bash
# Ver se os partials existem
ls -la app/views/admin/*/\_search_results.html.erb

# Ver logs em tempo real
tail -f log/production.log

# Verificar se MeiliSearch está rodando
curl http://localhost:7700/health
```

A busca avançada deve funcionar perfeitamente após este fix!
