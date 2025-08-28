# Portal de Operadoras - Integrar Plus

## Visão Geral

O Portal de Operadoras é uma interface web dedicada para empresas operadoras de planos de saúde gerenciarem solicitações de encaminhamento para tratamentos especializados.

## Funcionalidades Implementadas

### 1. Sistema de Autenticação
- **Login e recuperação de senha** seguindo o mesmo padrão visual do sistema principal
- **Autenticação separada** para usuários externos (operadoras)
- **Controle de acesso** com verificação de usuário ativo

### 2. Gestão de Solicitações

#### Listagem de Solicitações
- Página inicial mostra todas as solicitações da operadora logada
- **Filtros disponíveis:**
  - Data de encaminhamento (intervalo entre datas)
  - Status da solicitação (aguardando/processado)
- **Informações exibidas:**
  - Nome do beneficiário
  - Convênio + código da carteira
  - Status (aguardando/processado)
  - Data de encaminhamento
  - Número de encaminhamentos

#### Criar Nova Solicitação
Formulário multiparte dividido em duas seções principais:

**🔹 Dados do Beneficiário:**
- Convênio (obrigatório)
- Código da carteira do plano de saúde (obrigatório)
- Tipo de convênio (select: particular/empresarial/familiar)
- CPF (com máscara 000.000.000-00)
- Nome completo (obrigatório)
- Data de nascimento (obrigatório)
- Endereço completo (obrigatório)
- Responsável (opcional)
- Data de encaminhamento (preenchida automaticamente, editável)

**🔹 Dados do Encaminhamento:**
- Botão "Adicionar Encaminhamento" permite múltiplos encaminhamentos
- Para cada encaminhamento:
  - CID (obrigatório)
  - Encaminhado para (select com opções: ABA, FONO, TO, PSICOPEDAGOGIA, PSICOLOGIA, PSICOMOTRICIDADE, FISIOTERAPIA, EQUOTERAPIA, MUSICOTERAPIA)
  - Médico (obrigatório)
  - Descrição (opcional)

#### Visualizar e Editar Solicitações
- **Visualização completa** de todos os dados da solicitação
- **Edição permitida** apenas para solicitações com status "aguardando"
- **Exclusão permitida** apenas para solicitações com status "aguardando"

### 3. Status de Solicitação
- **Aguardando:** Solicitação criada, pode ser editada/excluída
- **Processado:** Solicitação processada pelo time interno, somente leitura

## Arquitetura Técnica

### Modelos de Dados
- **ExternalUser:** Usuários externos (operadoras)
- **ServiceRequest:** Solicitações principais
- **ServiceRequestReferral:** Encaminhamentos (relacionamento 1:N)

### Controllers
- **Portal::BaseController:** Controller base com autenticação
- **Portal::ServiceRequestsController:** CRUD de solicitações
- **Portal::SessionsController:** Autenticação
- **Portal::PasswordsController:** Recuperação de senha

### Views e Componentes
- **Layout específico** para o portal (`layouts/portal.html.erb`)
- **Componentes reutilizáveis:**
  - `Portal::SidebarComponent`
  - `Portal::HeaderComponent`
- **Views responsivas** com TailwindCSS

### Funcionalidades JavaScript
- **Máscaras de CPF** com Stimulus
- **Formulários dinâmicos** para múltiplos encaminhamentos
- **Interface responsiva** para desktop e mobile

### Políticas de Acesso (Pundit)
- **ServiceRequestPolicy:** Controla acesso às solicitações
- **ServiceRequestReferralPolicy:** Controla acesso aos encaminhamentos
- Usuários só acessam suas próprias solicitações

## Rotas Principais

```
# Login/Logout
GET  /portal/sign_in   (login)
POST /portal/sign_out  (logout)

# Recuperação de senha
GET  /portal/password/new   (solicitar reset)
GET  /portal/password/edit  (alterar senha)

# Solicitações
GET    /portal/service_requests         (listagem)
GET    /portal/service_requests/new     (nova solicitação)
POST   /portal/service_requests         (criar)
GET    /portal/service_requests/:id     (visualizar)
GET    /portal/service_requests/:id/edit (editar)
PATCH  /portal/service_requests/:id     (atualizar)
DELETE /portal/service_requests/:id     (excluir)
```

## Dados de Exemplo

Para testes, o sistema inclui:
- **Usuário:** `operadora@exemplo.com` / `password123`
- **Empresa:** Operadora Saúde Exemplo
- **5 solicitações de exemplo** com diferentes status e encaminhamentos

## Segurança

- **Autenticação via Devise** com sessões separadas
- **Policies com Pundit** para controle de acesso
- **Validações rigorosas** nos modelos
- **CSRF protection** em todos os formulários
- **Sanitização de parâmetros** nos controllers

## Interface do Usuário

- **Design consistente** com o sistema principal
- **UI moderna** usando TailwindCSS
- **Responsiva** para desktop e mobile
- **Experiência otimizada** para operadoras
- **Navegação intuitiva** com sidebar dedicada

## Próximas Melhorias Sugeridas

1. **Notificações por email** quando status muda
2. **Exportação de relatórios** em PDF/Excel
3. **Dashboard com métricas** de solicitações
4. **Histórico de alterações** nas solicitações
5. **Upload de documentos** anexos
6. **API REST** para integração externa
7. **Busca avançada** por beneficiário/CID
8. **Painel administrativo** para gerenciar operadoras
