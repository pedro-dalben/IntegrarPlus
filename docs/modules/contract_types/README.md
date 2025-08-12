# Módulo ContractType - Formas de Contratação

## Objetivo

O módulo ContractType gerencia as formas de contratação disponíveis para profissionais, controlando quais campos são obrigatórios no cadastro de profissionais (empresa e CNPJ).

## Campos

- **name** (string, obrigatório, único): Nome da forma de contratação (ex: CLT, PJ, Autônomo)
- **requires_company** (boolean, default: false): Se o profissional deve informar o nome da empresa
- **requires_cnpj** (boolean, default: false): Se o profissional deve informar o CNPJ da empresa
- **description** (text, opcional): Descrição detalhada da forma de contratação

## Validações

- Nome é obrigatório e único (case-insensitive)
- `requires_cnpj` só pode ser `true` se `requires_company` for `true`
- Mensagem de erro amigável: "CNPJ só pode ser marcado se 'Requer Empresa' estiver ativo"

## Exemplos de Uso

### Tipos Padrão

1. **CLT**
   - `requires_company: false`
   - `requires_cnpj: false`
   - Descrição: Contrato de trabalho regido pela CLT

2. **PJ**
   - `requires_company: true`
   - `requires_cnpj: true`
   - Descrição: Contrato de prestação de serviços como empresa

3. **Autônomo**
   - `requires_company: false`
   - `requires_cnpj: false`
   - Descrição: Profissional autônomo sem vínculo empregatício

### Efeito no Formulário de Profissional

Quando um tipo de contratação é selecionado no formulário de profissional:

- Se `requires_company: true` → Campo "Nome da Empresa" é exibido
- Se `requires_cnpj: true` → Campo "CNPJ" é exibido
- Se `requires_cnpj: false` → Campo "CNPJ" é ocultado e limpo

## Rotas

- `GET /admin/contract_types` - Lista todas as formas de contratação
- `GET /admin/contract_types/new` - Formulário para criar nova
- `POST /admin/contract_types` - Cria nova forma de contratação
- `GET /admin/contract_types/:id/edit` - Formulário para editar
- `PATCH /admin/contract_types/:id` - Atualiza forma de contratação
- `DELETE /admin/contract_types/:id` - Remove forma de contratação

## Autorização

Todas as ações requerem a permissão `settings.read`.

## Integração com Profissional

O formulário de profissional usa o controller Stimulus `contract-fields` para:

1. Observar mudanças no select de ContractType
2. Mostrar/ocultar campos condicionalmente
3. Limpar valores quando campos são ocultados
4. Manter acessibilidade com `aria-hidden`

## Seeds

Os tipos padrão são criados automaticamente via `rails db:seed`:

```ruby
ContractType.find_or_create_by!(name: 'CLT') do |ct|
  ct.requires_company = false
  ct.requires_cnpj = false
  ct.description = 'Consolidação das Leis do Trabalho...'
end
```
