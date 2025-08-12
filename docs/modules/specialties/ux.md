# UX - Multiselect Dependente de Especialidades e Especializações

## Comportamento Esperado

### Seleção de Especialidades
- **Múltipla**: Usuário pode selecionar várias especialidades
- **Busca**: Campo de busca em tempo real
- **Placeholder**: "Selecione especialidades..."
- **Remoção**: Botão X para remover cada item selecionado

### Seleção de Especializações
- **Dependente**: Opções baseadas nas especialidades selecionadas
- **Múltipla**: Usuário pode selecionar várias especializações
- **Busca**: Campo de busca em tempo real
- **Placeholder**: "Selecione especializações..."
- **Remoção**: Botão X para remover cada item selecionado

## Fluxo de Interação

### Cenário 1: Seleção Inicial
1. **Estado inicial**: Ambos os selects vazios
2. **Usuário seleciona "Psicologia"**: Especializações são carregadas
3. **Resultado**: Select de especializações mostra apenas opções de Psicologia

### Cenário 2: Múltiplas Especialidades
1. **Usuário seleciona "Psicologia"**: Especializações de Psicologia aparecem
2. **Usuário adiciona "Fonoaudiologia"**: Especializações de ambas aparecem
3. **Resultado**: Select de especializações mostra opções de Psicologia + Fonoaudiologia

### Cenário 3: Remoção de Especialidade
1. **Estado**: Psicologia + Fonoaudiologia selecionadas
2. **Usuário remove "Psicologia"**: Especializações de Psicologia são removidas
3. **Seleções inválidas**: Especializações de Psicologia são desmarcadas automaticamente
4. **Resultado**: Apenas especializações de Fonoaudiologia permanecem

### Cenário 4: Limpeza Completa
1. **Estado**: Especialidades e especializações selecionadas
2. **Usuário remove todas as especialidades**: Especializações são limpas
3. **Resultado**: Select de especializações fica vazio

## Controller Stimulus: dependent-specializations

### Funcionalidades Principais

#### 1. Observação de Mudanças
```javascript
data-action="change->dependent-specializations#specialityChanged"
```
- Monitora mudanças no select de especialidades
- Reage imediatamente a seleções/desseleções

#### 2. Fetch Dinâmico
```javascript
async fetchSpecializations(specialityIds) {
  const params = new URLSearchParams()
  specialityIds.forEach(id => params.append('speciality_ids[]', id))
  
  return fetch(`${this.endpointValue}?${params.toString()}`)
}
```
- Faz requisição AJAX para endpoint JSON
- Filtra por IDs das especialidades selecionadas

#### 3. Atualização de Opções
```javascript
updateSpecializationOptions(specializations) {
  // Limpa opções existentes
  // Adiciona novas opções
  // Restaura valores válidos
}
```
- Limpa opções antigas
- Adiciona novas opções baseadas na resposta
- Preserva seleções válidas

#### 4. Preservação de Seleções
```javascript
preserveValidSelections(specializations) {
  const validIds = specializations.map(s => s.id.toString())
  
  // Desmarca opções inválidas
  // Mantém opções válidas
}
```
- Identifica seleções válidas
- Remove seleções inválidas automaticamente
- Mantém seleções que ainda são válidas

### Integração com Tom-Select

#### Inicialização
```javascript
// Controller tom-select inicializa os selects
data-controller="tom-select dependent-specializations"
```

#### Re-inicialização
```javascript
reinitializeTomSelect() {
  const tomSelectInstance = this.specializationSelectTarget.tomselect
  if (tomSelectInstance) {
    tomSelectInstance.refreshOptions()
    tomSelectInstance.refreshItems()
  }
}
```
- Re-inicializa tom-select após mudanças
- Atualiza interface visual
- Mantém funcionalidades de busca

## Estados Visuais

### Estado Inicial
- **Especialidades**: Select vazio com placeholder
- **Especializações**: Select vazio com placeholder
- **Ação**: Usuário deve selecionar especialidades primeiro

### Estado com Especialidades Selecionadas
- **Especialidades**: Itens selecionados com botão X
- **Especializações**: Opções filtradas disponíveis
- **Ação**: Usuário pode selecionar especializações

### Estado Completo
- **Especialidades**: Múltiplos itens selecionados
- **Especializações**: Múltiplos itens selecionados
- **Validação**: Todas as especializações são válidas para as especialidades

### Estado de Transição
- **Especialidades**: Mudança em andamento
- **Especializações**: Carregando ou atualizando
- **Feedback**: Indicador visual de carregamento (opcional)

## Acessibilidade

### Labels e Descrições
```html
<label for="professional_speciality_ids">Especialidades</label>
<select id="professional_speciality_ids" 
        aria-describedby="speciality-help">
  <!-- opções -->
</select>
<p id="speciality-help">Selecione as especialidades do profissional</p>
```

### Navegação por Teclado
- **Tab**: Navega entre os selects
- **Enter**: Abre/fecha dropdown
- **Escape**: Fecha dropdown
- **Setas**: Navega pelas opções
- **Space**: Seleciona/desseleciona

### Screen Readers
- **ARIA**: Labels e descrições apropriadas
- **Estados**: Anúncio de mudanças dinâmicas
- **Relacionamentos**: Indicação de dependência

## Validação

### Frontend (Stimulus)
- **Seleções válidas**: Apenas especializações das especialidades selecionadas
- **Limpeza automática**: Remoção de seleções inválidas
- **Feedback visual**: Indicação de estados

### Backend (Rails)
- **Validação condicional**: Especializações devem pertencer às especialidades
- **Mensagens de erro**: Contextuais e claras
- **Integridade**: Manutenção de relacionamentos

## Casos de Uso

### Profissional Multidisciplinar
1. **Seleciona**: Fonoaudiologia + Psicologia
2. **Especializações**: Linguagem + ABA + Neuropsicologia
3. **Resultado**: Profissional com múltiplas especialidades

### Mudança de Foco
1. **Estado**: Psicologia + especializações selecionadas
2. **Remove**: Psicologia
3. **Adiciona**: Terapia Ocupacional
4. **Resultado**: Especializações de TO disponíveis

### Limpeza e Recomeço
1. **Estado**: Múltiplas seleções
2. **Remove**: Todas as especialidades
3. **Resultado**: Formulário limpo para nova seleção
