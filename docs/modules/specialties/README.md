# Módulo Specialties - Especialidades e Especializações

## Objetivo

O módulo Specialties gerencia especialidades e suas especializações com relação 1:N, preparando o multiselect dependente para o formulário de Profissional.

## Modelagem de Dados

### Speciality (Especialidade)
- **name** (string, obrigatório, único): Nome da especialidade
- **specializations** (has_many): Especializações associadas
- **professionals** (has_many through): Profissionais associados

### Specialization (Especialização)
- **name** (string, obrigatório, único): Nome da especialização
- **speciality** (belongs_to): Especialidade à qual pertence
- **professionals** (has_many through): Profissionais associados

### Relacionamentos
- **Speciality 1:N Specialization**: Uma especialidade pode ter múltiplas especializações
- **Professional N:N Speciality**: Profissionais podem ter múltiplas especialidades
- **Professional N:N Specialization**: Profissionais podem ter múltiplas especializações

## Rotas

### Especialidades
- `GET /admin/specialities` - Lista todas as especialidades
- `GET /admin/specialities/new` - Formulário para criar nova
- `POST /admin/specialities` - Cria nova especialidade
- `GET /admin/specialities/:id/edit` - Formulário para editar
- `PATCH /admin/specialities/:id` - Atualiza especialidade
- `DELETE /admin/specialities/:id` - Remove especialidade

### Especializações
- `GET /admin/specializations` - Lista todas as especializações
- `GET /admin/specializations/new` - Formulário para criar nova
- `POST /admin/specializations` - Cria nova especialização
- `GET /admin/specializations/:id/edit` - Formulário para editar
- `PATCH /admin/specializations/:id` - Atualiza especialização
- `DELETE /admin/specializations/:id` - Remove especialização

### Endpoint JSON
- `GET /admin/specializations.json?speciality_ids[]=1&speciality_ids[]=2` - Retorna especializações filtradas por especialidades

## Autorização

Todas as ações requerem a permissão `settings.read`.

## Controllers Stimulus

### tom-select
Inicializa selects múltiplos com busca, placeholder e funcionalidade de remoção.

**Funcionalidades:**
- Busca em tempo real
- Placeholder customizável
- Botão de remoção de itens
- Suporte a seleção múltipla

### dependent-specializations
Controla a dependência entre especialidades e especializações.

**Funcionalidades:**
- Observa mudanças no select de especialidades
- Faz fetch no endpoint JSON
- Atualiza opções do select de especializações
- Preserva seleções válidas
- Remove seleções inválidas
- Suporte a Turbo

## Exemplos de Uso

### Tipos Padrão

#### Fonoaudiologia
- Linguagem
- Motricidade Orofacial
- Neurodesenvolvimento
- Audiologia
- Voz

#### Psicologia
- ABA
- Neuropsicologia
- Terapia Cognitivo-Comportamental
- Psicopedagogia
- Psicologia Clínica

#### Terapia Ocupacional
- Integração Sensorial
- Pediatria
- Reabilitação Neurológica
- Saúde Mental
- Reabilitação Física

### Implementação no Formulário de Profissional

```html
<div data-controller="tom-select dependent-specializations" 
     data-dependent-specializations-endpoint-value="/admin/specializations.json">
  
  <!-- Select de Especialidades -->
  <select data-tom-select-target="select" 
          data-dependent-specializations-target="specialitySelect"
          data-action="change->dependent-specializations#specialityChanged"
          multiple>
    <option value="">Selecione especialidades...</option>
    <% Speciality.ordered.each do |speciality| %>
      <option value="<%= speciality.id %>"><%= speciality.name %></option>
    <% end %>
  </select>

  <!-- Select de Especializações -->
  <select data-tom-select-target="select" 
          data-dependent-specializations-target="specializationSelect"
          multiple>
    <option value="">Selecione especializações...</option>
  </select>
</div>
```

## Seeds

Os dados padrão são criados automaticamente via `rails db:seed`:

```ruby
specialities_data = [
  {
    name: 'Fonoaudiologia',
    specializations: ['Linguagem', 'Motricidade Orofacial', ...]
  },
  # ...
]

specialities_data.each do |speciality_data|
  speciality = Speciality.find_or_create_by!(name: speciality_data[:name])
  
  speciality_data[:specializations].each do |spec_name|
    Specialization.find_or_create_by!(name: spec_name, speciality: speciality)
  end
end
```

## Próximos Passos

### Para o Formulário de Profissional
1. Adicionar campos `speciality_ids[]` e `specialization_ids[]` ao modelo Professional
2. Implementar validação condicional
3. Usar os controllers Stimulus conforme exemplo acima

### Tabelas de Relacionamento
As tabelas `professional_specialities` e `professional_specializations` serão criadas quando o modelo Professional for implementado.
