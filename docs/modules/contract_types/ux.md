# UX - Campos Condicionais por Tipo de Contratação

## Comportamento dos Flags

### requires_company

**Quando `true`:**
- Campo "Nome da Empresa" é exibido no formulário de profissional
- Campo se torna obrigatório para validação
- Usuário deve preencher o nome da empresa contratante

**Quando `false`:**
- Campo "Nome da Empresa" é ocultado
- Valor é limpo automaticamente
- Não é validado no backend

### requires_cnpj

**Quando `true`:**
- Campo "CNPJ" é exibido no formulário de profissional
- Campo se torna obrigatório para validação
- Usuário deve preencher o CNPJ da empresa

**Quando `false`:**
- Campo "CNPJ" é ocultado
- Valor é limpo automaticamente
- Não é validado no backend

**Restrição:** Só pode ser `true` se `requires_company` for `true`

## Controller Stimulus: contract-fields

### Funcionalidades

1. **Observação de Mudanças**
   - Monitora o select de ContractType
   - Reage imediatamente a mudanças de seleção

2. **Exibição Condicional**
   - Mostra/oculta campos com transições suaves
   - Usa classes CSS para animações (`opacity-0`, `opacity-100`)

3. **Limpeza Automática**
   - Limpa valores quando campos são ocultados
   - Evita dados inconsistentes

4. **Acessibilidade**
   - Mantém `aria-hidden` atualizado
   - Preserva navegação por teclado
   - Suporte a leitores de tela

### Implementação no Formulário

```html
<div data-controller="contract-fields" 
     data-contract-fields-contract-types-value="<%= @contract_types.to_json %>"
     data-contract-fields-current-type-value="<%= @professional.contract_type_id %>">
  
  <!-- Select de ContractType -->
  <select data-action="change->contract-fields#contractTypeChanged">
    <option value="">Selecione...</option>
    <% @contract_types.each do |type| %>
      <option value="<%= type.id %>"><%= type.name %></option>
    <% end %>
  </select>

  <!-- Campo condicional: Empresa -->
  <div data-contract-fields-target="companyField" style="display: none;">
    <label>Nome da Empresa</label>
    <input type="text" name="professional[company_name]">
  </div>

  <!-- Campo condicional: CNPJ -->
  <div data-contract-fields-target="cnpjField" style="display: none;">
    <label>CNPJ</label>
    <input type="text" name="professional[cnpj]">
  </div>
</div>
```

### Estados Visuais

#### Estado Inicial
- Select vazio ou sem seleção
- Campos de empresa e CNPJ ocultos

#### CLT Selecionado
- Campo empresa: oculto
- Campo CNPJ: oculto
- Formulário mais limpo e simples

#### PJ Selecionado
- Campo empresa: visível e obrigatório
- Campo CNPJ: visível e obrigatório
- Formulário completo para dados empresariais

#### Autônomo Selecionado
- Campo empresa: oculto
- Campo CNPJ: oculto
- Formulário focado em dados pessoais

## Transições e Animações

### Exibição
```css
.opacity-0 {
  opacity: 0;
  pointer-events: none;
}

.opacity-100 {
  opacity: 1;
  transition: opacity 0.2s ease-in-out;
}
```

### Comportamento
- Duração: 200ms
- Easing: ease-in-out
- Campos aparecem/desaparecem suavemente
- Não interfere na usabilidade

## Validação

### Frontend (Stimulus)
- Campos ocultos não são validados
- Valores são limpos automaticamente
- Feedback visual imediato

### Backend (Rails)
- Validação condicional baseada no ContractType
- Campos obrigatórios apenas quando necessário
- Mensagens de erro contextuais

## Casos de Uso

### Cenário 1: Profissional CLT
1. Usuário seleciona "CLT"
2. Campos empresa/CNPJ são ocultados
3. Formulário fica mais simples
4. Foco nos dados pessoais

### Cenário 2: Profissional PJ
1. Usuário seleciona "PJ"
2. Campos empresa/CNPJ são exibidos
3. Formulário expande para dados empresariais
4. Validação completa

### Cenário 3: Mudança de Tipo
1. Usuário muda de "PJ" para "CLT"
2. Campos empresa/CNPJ são ocultados
3. Valores são limpos automaticamente
4. Transição suave e intuitiva
