# 🔄 Migração de Scripts Inline para Stimulus Controllers

## Objetivo

Este documento orienta a migração de scripts inline (`<script>` tags em views `.erb`) para Stimulus controllers, seguindo as melhores práticas do projeto.

## ✅ Controller Criado: `toggle-fields`

### Localização
`app/frontend/javascript/controllers/toggle_fields_controller.js`

### Funcionalidade
Controller genérico para mostrar/ocultar campos baseado no estado de um checkbox.

### Uso

#### Antes (Script Inline)
```erb
<%= form.check_box :attends_school, id: "my_checkbox" %>

<div id="school-fields" style="display: none;">
  <!-- campos -->
</div>

<script>
  document.addEventListener('DOMContentLoaded', function() {
    const checkbox = document.getElementById('my_checkbox');
    const fields = document.getElementById('school-fields');

    if (checkbox) {
      checkbox.addEventListener('change', function() {
        fields.style.display = this.checked ? 'block' : 'none';
      });
    }
  });
</script>
```

#### Depois (Stimulus Controller)
```erb
<div data-controller="toggle-fields">
  <%= form.check_box :attends_school,
      data: {
        toggle_fields_target: "trigger",
        action: "change->toggle-fields#update"
      } %>

  <div data-toggle-fields-target="content"
       style="<%= 'display: none;' unless model.attends_school? %>">
    <!-- campos -->
  </div>
</div>
```

### Opções

#### Mostrar quando desmarcado
```erb
<div data-controller="toggle-fields"
     data-toggle-fields-show-when-value="unchecked">
  <!-- ... -->
</div>
```

## 📋 Arquivos Pendentes de Migração

### ✅ Migrados
- [x] `app/views/admin/beneficiaries/_form.html.erb` - Toggle escola
- [x] `app/views/admin/anamneses/_form.html.erb` - 3 toggles (escola, tratamento anterior, tratamento externo)

### Alta Prioridade (Scripts com event listeners simples)
- [ ] `app/views/portal/portal_intakes/new.html.erb` - Adicionar referrals (requer controller customizado)
- [ ] `app/views/admin/notifications/index.html.erb` - Dropdown handlers (requer análise)

### Média Prioridade (Scripts de inicialização complexa)
- [ ] `app/views/admin/flow_charts/show.html.erb` - Visualizador Draw.io (requer controller específico)
- [ ] `app/views/admin/organograms/show.html.erb` - Visualizador organogramas (requer controller específico)
- [ ] `app/views/admin/public_flow_charts/view.html.erb` - Visualizador público (requer controller específico)

### Baixa Prioridade (Páginas de teste/específicas)
- [ ] `app/views/admin/events/test_calendar.html.erb` - Teste de Stimulus (página de teste)
- [ ] `app/views/admin/portal_intakes/agenda_view.html.erb` - Visualização específica (avaliar necessidade)
- [ ] `app/views/admin/portal_intakes/schedule_anamnesis.html.erb` - Agendamento específico
- [ ] `app/views/admin/portal_intakes/reschedule_anamnesis.html.erb` - Reagendamento específico

### Notas de Migração

**Controllers Complexos Necessários:**
1. **ReferralController** - Para adicionar/remover campos de referral dinamicamente
2. **DrawioViewerController** - Para visualizar diagramas Draw.io
3. **OrganogramViewerController** - Para visualizar organogramas

**Decisão de Arquitetura:**
- Scripts simples de toggle → Usar `toggle_fields_controller` ✅
- Scripts de visualização → Criar controllers específicos
- Scripts de teste → Baixa prioridade, avaliar se vale migrar

## 🎯 Benefícios da Migração

1. **Compatibilidade com Turbo**: Controllers Stimulus são automaticamente reconectados
2. **Reutilização**: Controllers genéricos podem ser usados em múltiplos lugares
3. **Manutenibilidade**: Código JavaScript centralizado e testável
4. **Performance**: Sem duplicação de event listeners
5. **Boas Práticas**: Separação de concerns (HTML/CSS/JS)

## 📝 Checklist de Migração

Para cada script inline:

- [ ] Identificar funcionalidade do script
- [ ] Verificar se existe controller Stimulus equivalente
- [ ] Se não existir, criar controller genérico e reutilizável
- [ ] Adicionar data-attributes na view
- [ ] Remover script inline
- [ ] Testar funcionalidade após migração
- [ ] Verificar comportamento com navegação Turbo

## 🔧 Controllers Disponíveis

### `toggle-fields` - Toggle de campos
**Uso**: Mostrar/ocultar campos baseado em checkbox
**Arquivo**: `toggle_fields_controller.js`

### `dropdown` - Dropdowns do menu
**Uso**: Controlar abertura/fechamento de dropdowns
**Arquivo**: `dropdown_controller.js`

### `sidebar` - Menu lateral
**Uso**: Controlar sidebar responsiva
**Arquivo**: `sidebar_controller.js`

### `drawio` - Editor de fluxogramas
**Uso**: Integração com Draw.io
**Arquivo**: `drawio_controller.js`

### `anamneses-filters` - Filtros de anamneses
**Uso**: Modal de filtros avançados
**Arquivo**: `anamneses_filters_controller.js`

## 🚀 Próximos Passos

1. Migrar scripts inline restantes seguindo este guia
2. Criar controllers adicionais conforme necessário
3. Documentar novos controllers neste arquivo
4. Atualizar PROJECT_RULES.md com exemplos práticos
