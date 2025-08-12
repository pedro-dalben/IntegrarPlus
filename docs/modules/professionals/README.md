# Módulo Professionals - Gestão de Profissionais

## Objetivo

O módulo Professionals gerencia o cadastro completo de profissionais com integração a ContractType, Specialities/Specializations e Groups, incluindo funcionalidades administrativas de confirmação e reset de senha.

## Modelagem de Dados

### Professional (Devise)
- **full_name** (string, obrigatório): Nome completo do profissional
- **birth_date** (date, opcional): Data de nascimento (≥ 1900, ≤ hoje)
- **cpf** (string, obrigatório, único): CPF formatado BR
- **phone** (string, opcional): Telefone formatado BR
- **email** (string, obrigatório, único): E-mail (Devise)
- **active** (boolean, default: true): Status ativo/inativo
- **contract_type** (references, opcional): Forma de contratação
- **hired_on** (date, opcional): Data de contratação
- **workload_minutes** (integer, obrigatório, default: 0): Carga horária em minutos
- **council_code** (string, opcional): Código do conselho profissional
- **company_name** (string, opcional): Nome da empresa (condicional)
- **cnpj** (string, opcional): CNPJ formatado BR (condicional)

### Relacionamentos
- **Professional N:N Group**: Profissionais podem pertencer a múltiplos grupos
- **Professional N:N Speciality**: Profissionais podem ter múltiplas especialidades
- **Professional N:N Specialization**: Profissionais podem ter múltiplas especializações
- **Professional 1:N ContractType**: Profissional tem uma forma de contratação

## Rotas

### CRUD Principal
- `GET /admin/professionals` - Lista todos os profissionais
- `GET /admin/professionals/:id` - Detalhes do profissional
- `GET /admin/professionals/new` - Formulário para criar novo
- `POST /admin/professionals` - Cria novo profissional
- `GET /admin/professionals/:id/edit` - Formulário para editar
- `PATCH /admin/professionals/:id` - Atualiza profissional
- `DELETE /admin/professionals/:id` - Remove profissional

### Ações Administrativas
- `POST /admin/professionals/:id/resend_confirmation` - Reenvia e-mail de confirmação
- `POST /admin/professionals/:id/send_reset_password` - Envia e-mail de reset de senha
- `POST /admin/professionals/:id/force_confirm` - Força confirmação manual

## Autorização

- **professionals.read**: Para visualizar lista e detalhes
- **professionals.manage**: Para criar, editar, excluir e ações administrativas

## Controllers Stimulus

### mask
Aplica máscaras em campos de entrada (CPF, CNPJ, telefone).

**Tipos:**
- `cpf`: 000.000.000-00
- `cnpj`: 00.000.000/0000-00
- `phone`: (00) 00000-0000 ou (00) 0000-0000

### time-hhmm
Converte entrada HH:MM para minutos no campo hidden.

**Funcionalidades:**
- Validação de formato (00:00–99:59)
- Conversão automática para minutos
- Máximo 99:59 (5999 minutos)

### tom-select
Inicializa selects múltiplos com busca e funcionalidades avançadas.

**Usado em:**
- Grupos
- Especialidades
- Especializações

### dependent-specializations
Controla dependência entre especialidades e especializações.

**Funcionalidades:**
- Observa mudanças no select de especialidades
- Carrega especializações via endpoint JSON
- Preserva seleções válidas
- Remove seleções inválidas

### contract-fields
Controla exibição de campos condicionais baseado no ContractType.

**Campos condicionais:**
- `company_name`: aparece se `requires_company = true`
- `cnpj`: aparece se `requires_cnpj = true`

### flash
Gerencia mensagens flash com auto-dismiss.

### search
Busca simples client-side na tabela de profissionais.

### row
Navegação por clique em linha da tabela.

### dropdown
Menu dropdown para ações administrativas.

## Validações

### Campos Obrigatórios
- `full_name`: Nome completo
- `cpf`: CPF válido e único
- `email`: E-mail válido e único
- `workload_minutes`: ≥ 0

### Validações Condicionais
- **ContractType**: Se `requires_company` → `company_name` obrigatório
- **ContractType**: Se `requires_cnpj` → `cnpj` obrigatório
- **Especializações**: Devem pertencer às especialidades selecionadas

### Validações de Formato
- **CPF**: Formato BR válido
- **CNPJ**: Formato BR válido (quando presente)
- **Telefone**: Formato BR válido (quando presente)
- **Data de Nascimento**: ≥ 1900 e ≤ hoje

## Funcionalidades Especiais

### Conversão HH:MM → Minutos
- Input visual: HH:MM (ex: 40:00)
- Armazenamento: minutos (ex: 2400)
- Conversão automática via Stimulus

### Campos Condicionais
- **CLT**: Não mostra empresa/CNPJ
- **PJ**: Mostra empresa e CNPJ obrigatórios
- **Autônomo**: Não mostra empresa/CNPJ

### Ações Administrativas
- **Reenviar confirmação**: Dispara e-mail Devise (limite 1h)
- **Resetar senha**: Envia e-mail de recuperação
- **Forçar confirmação**: Confirma manualmente (apenas admin)

### Status de Acesso
- **Ativo**: Pode fazer login
- **Inativo**: Bloqueado no login
- **Confirmado**: E-mail confirmado
- **Pendente**: Aguardando confirmação

## Integrações

### ContractType
- Determina campos obrigatórios (empresa/CNPJ)
- Validação condicional no backend
- Controle de exibição no frontend

### Specialities/Specializations
- Seleção múltipla de especialidades
- Especializações dependentes via endpoint JSON
- Validação de consistência

### Groups
- Seleção múltipla de grupos
- Controle de permissões (futuro)

## Exemplos de Uso

### Criar Profissional CLT
1. Preencher dados pessoais
2. Selecionar "CLT" como forma de contratação
3. Campos empresa/CNPJ não aparecem
4. Definir carga horária (ex: 40:00)
5. Selecionar especialidades e especializações

### Criar Profissional PJ
1. Preencher dados pessoais
2. Selecionar "PJ" como forma de contratação
3. Campos empresa e CNPJ aparecem obrigatórios
4. Preencher dados da empresa
5. Definir carga horária e especialidades

### Ações Administrativas
1. **Profissional não confirmado**: Reenviar confirmação
2. **Esqueceu senha**: Resetar senha
3. **Problemas com e-mail**: Forçar confirmação
4. **Inativo**: Desativar acesso

## Próximos Passos

### Funcionalidades Futuras
- Logs de auditoria
- Histórico de atividades
- Notificações automáticas
- Integração com sistema de permissões
- Relatórios e dashboards

### Melhorias Técnicas
- Validação de CPF/CNPJ mais robusta
- Cache de especializações
- Paginação na listagem
- Filtros avançados
- Exportação de dados
