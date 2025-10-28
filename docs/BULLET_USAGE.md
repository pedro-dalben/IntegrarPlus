# 🔫 Guia de Uso do Bullet - N+1 Query Detection

**Data**: 28 de Outubro de 2025
**Status**: ✅ Configurado

---

## 📋 O que é Bullet?

Bullet é uma gem que detecta:
- **N+1 queries**: Quando você faz múltiplas queries que poderiam ser uma só
- **Unused eager loading**: Quando você carrega associações que não usa
- **Counter cache**: Quando você deveria usar counter cache

---

## 🎯 Como Usar

### 1. Console do Navegador (RECOMENDADO) 🆕

As mensagens do Bullet agora aparecem automaticamente no **console do navegador** com formatação colorida!

**Como ver**:
1. Abra o DevTools (F12 ou Cmd+Option+I)
2. Vá na aba **Console**
3. Navegue pela aplicação
4. Os alertas do Bullet aparecerão automaticamente

**Formato das Mensagens**:
```
🔫 Bullet N+1 Query Detection
  ⚠️  USE eager loading detected
  ❌ Beneficiary => [:anamneses, :portal_intake]
  🔍 query: .includes([:anamneses, :portal_intake])
  📂 /app/views/admin/beneficiaries/_table.html.erb:30
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 Para copiar: Clique com botão direito na mensagem e selecione "Copy"
```

**Como copiar as mensagens**:
- Clique com **botão direito** na mensagem
- Selecione **"Copy message"**
- Cole onde quiser!

---

### 2. Footer da Página

No rodapé das páginas (em desenvolvimento), você verá um banner vermelho com os alertas do Bullet.

---

### 3. Terminal Rails

As mensagens também aparecem no terminal onde você executou `bin/dev`:

```bash
USE eager loading detected:
  Beneficiary => [:anamneses, :portal_intake]
  Add to your query: .includes([:anamneses, :portal_intake])
```

---

### 4. Arquivo de Log

Todas as detecções são salvas em:
```
log/bullet.log
```

**Ver log em tempo real**:
```bash
tail -f log/bullet.log
```

---

## 🔍 Tipos de Alertas

### ⚠️ N+1 Query Detection

**Mensagem**:
```
USE eager loading detected
  Beneficiary => [:anamneses, :portal_intake]
  Add to your query: .includes([:anamneses, :portal_intake])
```

**O que significa**:
Você está iterando sobre beneficiaries e acessando `anamneses` ou `portal_intake` dentro do loop, causando uma query para cada beneficiary.

**Como corrigir**:
```ruby
# ❌ ERRADO
@beneficiaries = Beneficiary.all
# View: @beneficiaries.each { |b| b.anamneses.count }

# ✅ CORRETO
@beneficiaries = Beneficiary.includes(:anamneses).all
```

---

### 📊 Unused Eager Loading

**Mensagem**:
```
AVOID eager loading detected
  Beneficiary => [:portal_intake]
  Remove from your query: .includes([:portal_intake])
```

**O que significa**:
Você carregou `portal_intake` mas não usou na view.

**Como corrigir**:
```ruby
# Se não usa portal_intake na view, remova do includes
@beneficiaries = Beneficiary.includes(:anamneses).all
```

---

### 🔢 Counter Cache

**Mensagem**:
```
Need counter cache
  Beneficiary => [:anamneses]
  Consider adding counter cache
```

**O que significa**:
Você está usando `.count` muitas vezes. Considere adicionar counter cache para melhor performance.

**Como implementar**:
```ruby
# Migration
add_column :beneficiaries, :anamneses_count, :integer, default: 0

# Model
class Anamnesis < ApplicationRecord
  belongs_to :beneficiary, counter_cache: true
end

# Depois, resete os contadores
Beneficiary.find_each { |b| Beneficiary.reset_counters(b.id, :anamneses) }
```

---

## 🛠️ Comandos Úteis

### Verificar N+1 automaticamente
```bash
bundle exec rails performance:check_n_plus_one
```

### Ver sugestões de includes por model
```bash
bundle exec rails performance:suggest_includes
```

### Limpar log do Bullet
```bash
> log/bullet.log
```

---

## 📝 Workflow de Correção

### 1. Detectar
- Navegue pela aplicação
- Observe alertas no **console do navegador**
- Copie a mensagem

### 2. Analisar
- Identifique qual controller/action
- Veja quais associações estão sendo acessadas
- Verifique a view correspondente

### 3. Corrigir
```ruby
# No controller, adicione includes:
@records = Model.includes(:association1, :association2).all

# Para associações aninhadas:
@records = Model.includes(association: :nested_association).all

# Para múltiplas associações complexas:
@records = Model.includes(
  :simple_association,
  nested: [:deep_nested1, :deep_nested2]
).all
```

### 4. Testar
- Recarregue a página
- Verifique se o alerta sumiu
- Navegue para outras páginas

---

## 🚫 Desabilitar Bullet (Temporariamente)

Se precisar desabilitar o Bullet temporariamente:

```ruby
# config/environments/development.rb
config.after_initialize do
  Bullet.enable = false  # Mude para false
end
```

**Ou** apenas desabilite alerts no console:
```ruby
Bullet.footer_console_log = false
```

---

## 📚 Recursos

- **Documentação Bullet**: https://github.com/flyerhzm/bullet
- **Guia de Correção**: docs/N+1_QUERIES_FIX.md
- **Roadmap de Otimizações**: docs/OTIMIZACOES_ROADMAP.md

---

## 💡 Dicas

1. **Sempre** corrija N+1 queries assim que detectar
2. Use a **verificação automática** antes de cada PR
3. **Console do navegador** é a forma mais fácil de ver e copiar alertas
4. Mantenha o `log/bullet.log` limpo para facilitar debug
5. Execute a task de verificação regularmente

---

## 🎯 Meta

**Zero N+1 queries em produção!** 🚀

Toda vez que você ver um alerta do Bullet, é uma oportunidade de melhorar a performance da aplicação!

---

**Última atualização**: 28 de Outubro de 2025
**Versão**: 2.0 (com console do navegador)
