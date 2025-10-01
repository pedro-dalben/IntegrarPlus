# 📋 Sistema de Anamnese e Beneficiários - Implementação Completa

## 🎯 Visão Geral

Este documento detalha a implementação de um sistema completo de anamnese e gestão de beneficiários, integrado ao sistema de agendamentos existente. O sistema permitirá:

1. **Criação de beneficiários** (direta ou via fluxo portal> portal intakes >anamenese)
2. **Agendamento de anamnese** (já implementado)
3. **Tela de anamnese** para profissionais
4. **Formulário completo de anamnese**
5. **Geração automática de cadastro de beneficiário**

## 🏗️ Arquitetura do Sistema

### Fluxo Principal
```
Portal Intake → Agendamento Anamnese → Tela Anamnese → Formulário → Cadastro Beneficiário
```

### Componentes Principais
- **Beneficiary** (novo modelo)
- **Anamnesis** (novo modelo)
- **AnamnesisController** (novo controller)
- **BeneficiariesController** (novo controller)
- **Sistema de permissões** (extensão do existente)

## 📋 Tarefas de Implementação

### **FASE 0: Análise e Preparação**

#### 0.1 Análise do Sistema Atual
- [ ] **Auditoria do PortalIntake** - Mapear todos os campos existentes
  - [ ] Listar todos os campos da tabela `portal_intakes`
  - [ ] Identificar campos que serão migrados para `beneficiaries`
  - [ ] Documentar relacionamentos existentes
  - [ ] Verificar validações atuais
  - [ ] Analisar índices e performance

- [ ] **Análise de Agendamentos** - Verificar integração com MedicalAppointment
  - [ ] Mapear fluxo atual de agendamento de anamnese
  - [ ] Identificar pontos de integração necessários
  - [ ] Verificar status e transições de estado
  - [ ] Analisar relacionamentos com profissionais e agendas
  - [ ] Documentar métodos existentes de verificação de disponibilidade

- [ ] **Revisão de Permissões** - Mapear permissões atuais relacionadas
  - [ ] Listar todas as permissões existentes no sistema
  - [ ] Identificar permissões relacionadas a agendamentos
  - [ ] Verificar grupos existentes e suas permissões
  - [ ] Analisar políticas de acesso atuais
  - [ ] Documentar hierarquia de permissões

- [ ] **Análise de Performance** - Identificar possíveis gargalos
  - [ ] Verificar queries lentas relacionadas a agendamentos
  - [ ] Analisar uso de índices em tabelas relacionadas
  - [ ] Identificar N+1 queries existentes
  - [ ] Verificar uso de memória em operações de agendamento
  - [ ] Documentar métricas de performance atuais

#### 0.2 Definição de Regras de Negócio
- [ ] **Regras de Validação** - Definir validações específicas por campo
  - [ ] CPF: formato e algoritmo de validação
  - [ ] CEP: integração com API de validação
  - [ ] Email: formato e verificação de domínio
  - [ ] Telefone: formato brasileiro
  - [ ] Data de nascimento: idade mínima/máxima
  - [ ] Campos obrigatórios por tipo de anamnese
  - [ ] Validações condicionais (ex: se frequenta escola, nome é obrigatório)

- [ ] **Regras de Permissão** - Detalhar quem pode fazer o quê
  - [ ] Profissionais: apenas suas próprias anamneses
  - [ ] Coordenadores: todas as anamneses da equipe
  - [ ] Administradores: acesso total
  - [ ] Secretárias: apenas visualização e agendamento
  - [ ] Regras de edição: apenas anamneses não concluídas
  - [ ] Regras de exclusão: apenas administradores
  - [ ] Regras de transferência: entre profissionais

- [ ] **Regras de Workflow** - Definir fluxos de aprovação
  - [ ] Fluxo de criação de beneficiário via portal
  - [ ] Fluxo de agendamento de anamnese
  - [ ] Fluxo de preenchimento de anamnese
  - [ ] Fluxo de aprovação de anamnese
  - [ ] Fluxo de geração de cadastro
  - [ ] Fluxo de notificações
  - [ ] Fluxo de cancelamento/reagendamento

- [ ] **Regras de Auditoria** - Log de todas as alterações
  - [ ] Log de criação de beneficiários
  - [ ] Log de alterações em anamneses
  - [ ] Log de agendamentos e cancelamentos
  - [ ] Log de acessos a dados sensíveis
  - [ ] Log de alterações de permissões
  - [ ] Retenção de logs por período definido
  - [ ] Formato de logs padronizado

#### 0.3 Análise de Dados Existentes
- [ ] **Mapeamento de Dados** - Identificar dados a serem migrados
  - [ ] Dados de beneficiários em `portal_intakes`
  - [ ] Dados de agendamentos existentes
  - [ ] Dados de profissionais e agendas
  - [ ] Dados de permissões e grupos
  - [ ] Dados de configurações do sistema
  - [ ] Dados de logs e auditoria

- [ ] **Estratégia de Migração** - Planejar migração de dados
  - [ ] Scripts de migração de `portal_intakes` para `beneficiaries`
  - [ ] Migração de agendamentos existentes
  - [ ] Preservação de relacionamentos
  - [ ] Validação de integridade dos dados
  - [ ] Rollback em caso de problemas
  - [ ] Testes de migração em ambiente de desenvolvimento

#### 0.4 Análise de Integração
- [ ] **APIs Externas** - Identificar integrações necessárias
  - [ ] API do INEP para busca de escolas
  - [ ] API de CEP para validação de endereços
  - [ ] API de validação de CPF
  - [ ] Integração com sistema de notificações
  - [ ] Integração com sistema de relatórios
  - [ ] Rate limiting e tratamento de erros

- [ ] **Sistema de Notificações** - Planejar notificações
  - [ ] Notificações de agendamento
  - [ ] Lembretes de anamnese
  - [ ] Notificações de conclusão
  - [ ] Notificações de atraso
  - [ ] Canais de notificação (email, SMS, push)
  - [ ] Templates de notificação
  - [ ] Configurações de usuário

#### 0.5 Análise de Segurança
- [ ] **Proteção de Dados** - Implementar segurança
  - [ ] Criptografia de dados sensíveis
  - [ ] Controle de acesso granular
  - [ ] Logs de auditoria
  - [ ] Anonimização para relatórios
  - [ ] Política de retenção de dados
  - [ ] Conformidade com LGPD

- [ ] **Validação de Input** - Prevenir vulnerabilidades
  - [ ] Sanitização de dados de entrada
  - [ ] Validação de tipos de dados
  - [ ] Prevenção de SQL injection
  - [ ] Proteção contra XSS
  - [ ] Rate limiting
  - [ ] CSRF protection

#### 0.6 Análise de Performance
- [ ] **Otimizações de Banco** - Melhorar performance
  - [ ] Índices estratégicos para consultas frequentes
  - [ ] Paginação eficiente
  - [ ] Resolução de N+1 queries
  - [ ] Cache de dados frequentes
  - [ ] Otimização de queries complexas
  - [ ] Análise de plano de execução

- [ ] **Otimizações de Interface** - Melhorar UX
  - [ ] Lazy loading de componentes
  - [ ] Compressão de assets
  - [ ] Cache de páginas estáticas
  - [ ] Otimização de imagens
  - [ ] Minificação de CSS/JS
  - [ ] CDN para assets estáticos

#### 0.7 Definição de Testes
- [ ] **Estratégia de Testes** - Planejar cobertura de testes
  - [ ] Testes unitários para modelos
  - [ ] Testes de integração para controllers
  - [ ] Testes de sistema para fluxos completos
  - [ ] Testes de performance
  - [ ] Testes de segurança
  - [ ] Testes de acessibilidade
  - [ ] Cobertura mínima de 80%

- [ ] **Ambiente de Testes** - Configurar ambiente
  - [ ] Dados de teste realistas
  - [ ] Mocks para APIs externas
  - [ ] Configuração de CI/CD
  - [ ] Testes automatizados
  - [ ] Relatórios de cobertura
  - [ ] Integração com ferramentas de qualidade

#### 0.8 Documentação Técnica
- [ ] **Documentação de Arquitetura** - Documentar sistema
  - [ ] Diagramas de arquitetura
  - [ ] Fluxos de dados
  - [ ] Relacionamentos entre modelos
  - [ ] APIs e endpoints
  - [ ] Configurações do sistema
  - [ ] Guias de instalação e deploy

- [ ] **Documentação de Usuário** - Manuais e guias
  - [ ] Manual do administrador
  - [ ] Manual do profissional
  - [ ] Manual do coordenador
  - [ ] Guias de troubleshooting
  - [ ] FAQ
  - [ ] Vídeos tutoriais

### **FASE 1: Modelos e Banco de Dados**

#### 1.1 Criar Modelo Beneficiary
- [ ] **Criar migration** `create_beneficiaries.rb`
  - Campos básicos: nome, data_nascimento, cpf, telefone, email
  - Campos de endereço: endereco, cidade, estado, cep
  - Campos de responsável: nome_responsavel, telefone_responsavel, parentesco
  - Campos de escola: frequenta_escola, nome_escola, periodo_escola
  - Campos de identificação: cadastro_integrar (CI00000)
  - Relacionamentos: belongs_to :portal_intake (opcional)
  - Timestamps e índices

- [ ] **Criar modelo** `app/models/beneficiary.rb`
  - Validações básicas
  - Scopes para busca
  - Métodos de geração de identificador
  - Relacionamentos com anamnese e agendamentos

#### 1.2 Criar Modelo Anamnesis
- [ ] **Criar migration** `create_anamneses.rb`
  - Relacionamentos: belongs_to :beneficiary, belongs_to :professional, belongs_to :portal_intake
  - Campos de data: data_realizada, created_at, updated_at
  - Campos de motivo: motivo_encaminhamento, liminar, local_atendimento
  - Campos de horas: horas_pacote_encaminhado
  - Campos de especialidades (JSON ou tabela separada)
  - Campos de diagnóstico: diagnostico_concluido, medico_responsavel
  - Campos de tratamento: ja_realizou_tratamento, tratamentos_anteriores, vai_continuar_externo
  - Campos de horários: melhor_horario, horario_impossivel
  - Status: enum (pendente, em_andamento, concluida)

- [ ] **Criar modelo** `app/models/anamnesis.rb`
  - Validações
  - Scopes para filtros
  - Métodos de status
  - Relacionamentos

#### 1.3 Criar Modelo AnamnesisSpecialty (se necessário)
- [ ] **Criar migration** `create_anamnesis_specialties.rb`
  - belongs_to :anamnesis
  - Campos: specialty_type, quantity_sessions, quantity_hours, nao_especificado
  - Enum para tipos: fono, to, psicopedagogia, psicomotricidade, psicologia

### **FASE 2: Sistema de Permissões**

#### 2.1 Extender Permissões Existentes
- [ ] **Adicionar novas permissões** em `db/seeds/permissions.rb`
  ```ruby
  # Permissões de Beneficiários
  { key: 'beneficiaries.index', description: 'Listar beneficiários' },
  { key: 'beneficiaries.show', description: 'Ver detalhes do beneficiário' },
  { key: 'beneficiaries.create', description: 'Criar novos beneficiários' },
  { key: 'beneficiaries.edit', description: 'Editar beneficiários' },
  { key: 'beneficiaries.update', description: 'Atualizar beneficiários' },
  { key: 'beneficiaries.destroy', description: 'Excluir beneficiários' },
  
  # Permissões de Anamnese
  { key: 'anamneses.index', description: 'Listar anamneses' },
  { key: 'anamneses.show', description: 'Ver detalhes da anamnese' },
  { key: 'anamneses.create', description: 'Criar anamnese' },
  { key: 'anamneses.edit', description: 'Editar anamnese' },
  { key: 'anamneses.update', description: 'Atualizar anamnese' },
  { key: 'anamneses.complete', description: 'Concluir anamnese' },
  { key: 'anamneses.view_all', description: 'Ver todas as anamneses (não apenas próprias)' },
  ```

#### 2.2 Atualizar Grupos Existentes
- [ ] **Atualizar grupos** em `db/seeds/groups_setup.rb`
  - Adicionar permissões de beneficiários e anamnese aos grupos apropriados
  - Criar grupo específico para "Coordenadores de Anamnese" com permissão `anamneses.view_all`

### **FASE 3: Controllers e Rotas**

#### 3.1 BeneficiariesController
- [ ] **Criar** `app/controllers/admin/beneficiaries_controller.rb`
  - Actions: index, show, new, create, edit, update, destroy
  - Filtros: por nome, data, status
  - Busca avançada integrada
  - Paginação com Pagy

#### 3.2 AnamnesisController
- [ ] **Criar** `app/controllers/admin/anamneses_controller.rb`
  - Actions: index, show, new, create, edit, update, complete
  - Filtros: por data, profissional, status, beneficiário
  - Lógica de permissões (profissional vê apenas os seus, exceto se tiver permissão especial)
  - Integração com agendamentos existentes

#### 3.3 Atualizar Rotas
- [ ] **Adicionar rotas** em `config/routes.rb`
  ```ruby
  namespace :admin do
    resources :beneficiaries do
      resources :anamneses, except: [:index]
    end
    resources :anamneses, only: [:index, :show]
  end
  ```

### **FASE 4: Views e Interface**

#### 4.1 Menu de Navegação
- [ ] **Atualizar sidebar** em `app/views/layouts/admin.html.erb`
  - Adicionar menu "Beneficiários" com submenu:
    - Listar Beneficiários
    - Nova Anamnese
    - Agendamentos de Hoje

#### 4.2 Tela de Listagem de Anamneses
- [ ] **Criar** `app/views/admin/anamneses/index.html.erb`
  - Filtros por data, profissional, status
  - Lista de agendamentos do dia
  - Cards com informações resumidas
  - Ações: Ver, Editar, Concluir

#### 4.3 Formulário de Anamnese
- [ ] **Criar** `app/views/admin/anamneses/_form.html.erb`
  - Seção: Dados do Beneficiário (preenchimento automático)
  - Seção: Dados da Família (pai, mãe, responsável)
  - Seção: Dados Escolares
  - Seção: Motivo do Encaminhamento
  - Seção: Especialidades e Horas
  - Seção: Diagnóstico e Tratamentos
  - Seção: Horários Preferenciais

#### 4.4 Componentes ViewComponent
- [ ] **Criar** `app/components/anamnesis_card_component.rb`
- [ ] **Criar** `app/components/beneficiary_form_component.rb`
- [ ] **Criar** `app/components/anamnesis_form_component.rb`

### **FASE 5: Integração com Sistema Existente**

#### 5.1 Atualizar PortalIntakesController
- [ ] **Modificar** `app/controllers/admin/portal_intakes_controller.rb`
  - Após agendamento bem-sucedido, criar registro de anamnese pendente
  - Adicionar link para acessar anamnese diretamente

#### 5.2 Atualizar MedicalAppointment
- [ ] **Adicionar relacionamento** em `app/models/medical_appointment.rb`
  - belongs_to :anamnesis, optional: true
  - Método para verificar se é anamnese

#### 5.3 Service de Criação de Beneficiário
- [ ] **Criar** `app/services/beneficiary_creation_service.rb`
  - Lógica para criar beneficiário a partir de anamnese
  - Geração automática de identificador
  - Validações e transações

### **FASE 6: Funcionalidades Específicas**

#### 6.1 Geração de Identificador
- [ ] **Implementar** geração automática de CI00000
  - Sequencial único
  - Formato: CI + 5 dígitos
  - Validação de unicidade

#### 6.2 Integração com API de Escolas
- [ ] **Implementar** busca de escolas via API do INEP
  - Campo de busca com autocomplete
  - Validação de escola existente

#### 6.3 Sistema de Horários
- [ ] **Implementar** lógica de horários
  - Períodos: manhã, tarde
  - Horários específicos: início, meio, final
  - Validação de conflitos

### **FASE 7: Políticas e Autorização**

#### 7.1 BeneficiaryPolicy
- [ ] **Criar** `app/policies/admin/beneficiary_policy.rb`
  - Verificações de permissão
  - Scopes para listagem

#### 7.2 AnamnesisPolicy
- [ ] **Criar** `app/policies/admin/anamnesis_policy.rb`
  - Profissional vê apenas suas anamneses
  - Coordenadores veem todas
  - Verificações de edição e conclusão

### **FASE 8: Testes**

#### 8.1 Testes de Modelo
- [ ] **Criar** `spec/models/beneficiary_spec.rb`
- [ ] **Criar** `spec/models/anamnesis_spec.rb`
- [ ] **Criar** `spec/models/anamnesis_specialty_spec.rb`

#### 8.2 Testes de Controller
- [ ] **Criar** `spec/controllers/admin/beneficiaries_controller_spec.rb`
- [ ] **Criar** `spec/controllers/admin/anamneses_controller_spec.rb`

#### 8.3 Testes de Integração
- [ ] **Criar** `spec/requests/anamnesis_flow_spec.rb`
- [ ] **Criar** `spec/requests/beneficiary_creation_spec.rb`

### **FASE 9: Documentação**

#### 9.1 Documentação Técnica
- [ ] **Criar** `docs/ANAMNESE_SYSTEM.md`
  - Arquitetura do sistema
  - Fluxo de dados
  - APIs e endpoints

#### 9.2 Manual do Usuário
- [ ] **Criar** `docs/MANUAL_ANAMNESE.md`
  - Como criar beneficiário
  - Como preencher anamnese
  - Como gerenciar agendamentos

## 🔧 Detalhes Técnicos

### Estrutura de Dados da Anamnese

```ruby
# Campos principais
data_realizada: datetime
professional_id: integer
beneficiary_id: integer
portal_intake_id: integer (opcional)

# Dados da família
nome_pai: string
data_nascimento_pai: date
escolaridade_pai: string
profissao_pai: string

nome_mae: string
data_nascimento_mae: date
escolaridade_mae: string
profissao_mae: string

nome_responsavel: string
data_nascimento_responsavel: date
escolaridade_responsavel: string
profissao_responsavel: string

# Dados escolares
frequenta_escola: boolean
nome_escola: string
periodo_escola: enum (manha, tarde)

# Motivo do encaminhamento
motivo_encaminhamento: enum (aba, equipe_multi, aba_equipe_multi)
liminar: boolean
local_atendimento: enum (domiciliar, clinica, domiciliar_clinica, etc)
horas_pacote_encaminhado: integer (5-40)

# Especialidades (JSON ou tabela relacionada)
especialidades: json

# Diagnóstico
diagnostico_concluido: boolean
medico_responsavel: string

# Tratamentos
ja_realizou_tratamento: boolean
tratamentos_anteriores: json
vai_continuar_externo: boolean
tratamentos_externos: json

# Horários
melhor_horario: json
horario_impossivel: json

# Status
status: enum (pendente, em_andamento, concluida)
```

### Permissões por Grupo

```ruby
# Grupo: Profissionais
- beneficiaries.index
- beneficiaries.show
- anamneses.index (apenas próprias)
- anamneses.show (apenas próprias)
- anamneses.create
- anamneses.edit (apenas próprias)
- anamneses.update (apenas próprias)
- anamneses.complete (apenas próprias)

# Grupo: Coordenadores de Anamnese
- beneficiaries.index
- beneficiaries.show
- beneficiaries.create
- beneficiaries.edit
- beneficiaries.update
- anamneses.index (todas)
- anamneses.show (todas)
- anamneses.create
- anamneses.edit (todas)
- anamneses.update (todas)
- anamneses.complete (todas)
- anamneses.view_all

# Grupo: Administradores
- Todas as permissões
```

## 📅 Cronograma Estimado

- **Fase 0**: 3-4 dias (Análise e Preparação)
- **Fase 1-2**: 2-3 dias (Modelos e Permissões)
- **Fase 3**: 2-3 dias (Controllers e Rotas)
- **Fase 4**: 3-4 dias (Views e Interface)
- **Fase 5**: 2-3 dias (Integração)
- **Fase 6**: 2-3 dias (Funcionalidades)
- **Fase 7**: 1-2 dias (Políticas)
- **Fase 8**: 2-3 dias (Testes)
- **Fase 9**: 1 dia (Documentação)

**Total estimado**: 18-26 dias úteis

## 🚀 Próximos Passos

1. **Aprovação do escopo** e cronograma
2. **Início da Fase 0** - Análise e preparação do sistema atual
3. **Setup do ambiente** de desenvolvimento
4. **Implementação iterativa** seguindo as fases

## 📝 Notas Importantes

- **Integração com sistema existente**: Manter compatibilidade com agendamentos atuais
- **Permissões granulares**: Profissionais veem apenas suas anamneses por padrão
- **Geração automática**: Beneficiário criado automaticamente após anamnese concluída
- **Validações robustas**: Todos os campos obrigatórios devem ser validados
- **Interface responsiva**: Seguir padrões do TailAdmin existente
- **Testes abrangentes**: Cobertura completa de funcionalidades críticas
