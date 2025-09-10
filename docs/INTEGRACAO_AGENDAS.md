# Integração de Agendas - Guia Completo

## Visão Geral

Este documento explica como integrar o sistema de agendas com outras telas do sistema e como visualizar agendas existentes.

## Como Visualizar Agendas Existentes

### 1. Acessando a Lista de Agendas

Para visualizar todas as agendas disponíveis:

1. Navegue para **Admin > Agendas** (`/admin/agendas`)
2. Você verá uma lista com todas as agendas criadas
3. Cada agenda mostra:
   - Nome da agenda
   - Tipo de serviço (Anamnese, Consulta, etc.)
   - Status (Ativa, Rascunho, Arquivada)
   - Número de profissionais vinculados
   - Data de criação

### 2. Visualizando Detalhes de uma Agenda

Para ver os detalhes de uma agenda específica:

1. Clique em **"Ver"** na linha da agenda desejada
2. Na página de detalhes você verá:
   - **Configurações**: Nome, tipo, visibilidade, duração dos slots
   - **Profissionais**: Lista de profissionais vinculados
   - **Grade de Horários**: Resumo da configuração de horários
   - **Previsualização**: Slots disponíveis para os próximos 7 dias

### 3. Visualizando Grade de Horários da Agenda

Para ver a grade de horários completa de uma agenda:

1. **Durante o agendamento**: Na tela de agendamento, selecione uma agenda e clique em **"Ver Grade de Horários"**
2. **Visualização completa** que mostra:
   - **Informações da agenda**: Nome, tipo, duração, intervalo
   - **Profissionais disponíveis**: Lista de todos os profissionais vinculados
   - **Grade de horários**: Tabela visual com:
     - Navegação por semana (anterior/próxima)
     - Horários de funcionamento (08:00 às 16:50)
     - Slots de 50 minutos com intervalos de 10 minutos
     - Status visual: 🟢 Livre, 🔴 Ocupado, ⚪ Fora do horário
     - Dias úteis (segunda a sexta)
   - **Agendamentos existentes**: Lista de agendamentos já feitos
   - **Interação**: Clique em horários livres para agendar

### 4. Filtrando Agendas por Tipo

Para visualizar apenas agendas de anamnese:

1. Na lista de agendas, use o filtro **"Tipo de Serviço"**
2. Selecione **"Anamnese"**
3. A lista será filtrada mostrando apenas agendas de anamnese

## Como Integrar Agendas em uma Nova Tela

### 1. Estrutura Básica

Para integrar o sistema de agendas em uma nova tela, você precisará:

#### Controller
```ruby
# app/controllers/admin/sua_controller.rb
def schedule_appointment
  authorize @seu_modelo, policy_class: Admin::SuaPolicy
  
  # Buscar agendas ativas do tipo desejado
  @agendas = Agenda.active.by_service_type(:seu_tipo).includes(:professionals)
  
  if request.post?
    agenda_id = params[:agenda_id]
    professional_id = params[:professional_id]
    scheduled_date = params[:scheduled_date]
    scheduled_time = params[:scheduled_time]
    
    if agenda_id.present? && professional_id.present? && 
       scheduled_date.present? && scheduled_time.present?
      begin
        scheduled_datetime = DateTime.parse("#{scheduled_date} #{scheduled_time}")
        
        # Criar o agendamento
        @seu_modelo.schedule_appointment!(scheduled_datetime, current_user)
        
        redirect_to admin_seu_modelo_path(@seu_modelo),
                    notice: 'Agendamento realizado com sucesso!'
      rescue StandardError => e
        flash.now[:alert] = "Erro ao agendar: #{e.message}"
        render :schedule_appointment
      end
    else
      flash.now[:alert] = 'Todos os campos são obrigatórios.'
      render :schedule_appointment
    end
  end
end
```

#### Rotas
```ruby
# config/routes.rb
resources :seu_modelo do
  member do
    get :schedule_appointment
    post :schedule_appointment
  end
end
```

#### View
```erb
<!-- app/views/admin/seu_modelo/schedule_appointment.html.erb -->
<% content_for(:title, "Agendar - #{@seu_modelo.nome}") %>

<div class="mb-6">
  <div class="md:flex md:items-center md:justify-between">
    <div class="flex-1 min-w-0">
      <h2 class="text-2xl font-bold leading-7 text-gray-900 dark:text-white sm:text-3xl sm:truncate">
        Agendar
      </h2>
      <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
        <%= @seu_modelo.nome %>
      </p>
    </div>
    <div class="flex items-center space-x-3">
      <%= link_to admin_seu_modelo_path(@seu_modelo), class: "ta-btn ta-btn-secondary" do %>
        <svg class="size-4 me-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
        </svg>
        Voltar
      <% end %>
    </div>
  </div>
</div>

<div class="space-y-6">
  <!-- Formulário de Agendamento -->
  <div class="rounded-2xl border border-gray-200 bg-white dark:border-gray-800 dark:bg-white/[0.03]">
    <div class="px-6 py-4 border-b border-gray-200 dark:border-gray-800">
      <h3 class="text-lg font-medium text-gray-900 dark:text-white">
        Selecionar Agenda e Horário
      </h3>
      <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
        Escolha a agenda, o profissional e o horário disponível
      </p>
    </div>
    <div class="p-6">
      <% if @agendas.any? %>
        <%= form_with url: schedule_appointment_admin_seu_modelo_path(@seu_modelo),
                      method: :post, local: true, 
                      data: { controller: "agenda-scheduler" },
                      class: "space-y-6" do |form| %>
          
          <!-- Seleção da Agenda -->
          <div>
            <%= form.label :agenda_id, "Agenda", class: "block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2" %>
            <%= form.select :agenda_id,
                           options_for_select(@agendas.map { |agenda| [agenda.name, agenda.id] }),
                           { prompt: "Selecione uma agenda" },
                           { 
                             class: "block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-white",
                             data: { 
                               action: "change->agenda-scheduler#onAgendaChange",
                               agenda_scheduler_target: "agendaSelect"
                             }
                           } %>
          </div>

          <!-- Seleção do Profissional -->
          <div data-agenda-scheduler-target="professionalSection" class="hidden">
            <%= form.label :professional_id, "Profissional", class: "block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2" %>
            <%= form.select :professional_id,
                           [],
                           { prompt: "Selecione um profissional" },
                           { 
                             class: "block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-white",
                             data: { 
                               action: "change->agenda-scheduler#onProfessionalChange",
                               agenda_scheduler_target: "professionalSelect"
                             }
                           } %>
          </div>

          <!-- Seleção da Data -->
          <div data-agenda-scheduler-target="dateSection" class="hidden">
            <%= form.label :scheduled_date, "Data", class: "block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2" %>
            <%= form.date_field :scheduled_date,
                               min: Date.current,
                               class: "block w-full max-w-xs rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-white",
                               data: { 
                                 action: "change->agenda-scheduler#onDateChange",
                                 agenda_scheduler_target: "dateSelect"
                               } %>
          </div>

          <!-- Seleção do Horário -->
          <div data-agenda-scheduler-target="timeSection" class="hidden">
            <%= form.label :scheduled_time, "Horário", class: "block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2" %>
            <%= form.select :scheduled_time,
                           [],
                           { prompt: "Selecione um horário" },
                           { 
                             class: "block w-full max-w-xs rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-white",
                             data: { 
                               action: "change->agenda-scheduler#onTimeChange",
                               agenda_scheduler_target: "timeSelect" 
                             }
                           } %>
          </div>

          <!-- Preview do Agendamento -->
          <div data-agenda-scheduler-target="previewSection" class="hidden">
            <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 dark:bg-blue-800/10 dark:border-blue-900">
              <h4 class="text-sm font-medium text-blue-900 dark:text-blue-400 mb-2">Resumo do Agendamento</h4>
              <div class="text-sm text-blue-700 dark:text-blue-300 space-y-1">
                <p><strong>Agenda:</strong> <span data-agenda-scheduler-target="agendaName">-</span></p>
                <p><strong>Profissional:</strong> <span data-agenda-scheduler-target="professionalName">-</span></p>
                <p><strong>Data e Horário:</strong> <span data-agenda-scheduler-target="scheduledDateTime">-</span></p>
              </div>
            </div>
          </div>

          <!-- Botões -->
          <div class="flex space-x-3">
            <%= form.submit "Confirmar Agendamento",
                           class: "ta-btn ta-btn-primary",
                           data: { 
                             confirm: "Confirma o agendamento?",
                             agenda_scheduler_target: "submitButton"
                           },
                           disabled: true %>
            <%= link_to "Cancelar", admin_seu_modelo_path(@seu_modelo), 
                        class: "ta-btn ta-btn-secondary" %>
          </div>
          
          <!-- Dados das agendas para JavaScript -->
          <script type="application/json" data-agenda-scheduler-target="agendasData">
            <%= @agendas.to_json(include: { professionals: { only: [:id, :name] } }).html_safe %>
          </script>
        <% end %>
      <% else %>
        <div class="text-center py-8">
          <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
          </svg>
          <h3 class="mt-4 text-sm font-medium text-gray-900 dark:text-gray-100">
            Nenhuma agenda disponível
          </h3>
          <p class="mt-1 text-sm text-gray-500 dark:text-gray-400">
            É necessário criar uma agenda ativa para poder agendar.
          </p>
          <div class="mt-4">
            <%= link_to "Criar Agenda", new_admin_agenda_path, 
                        class: "ta-btn ta-btn-primary" %>
          </div>
        </div>
      <% end %>
    </div>
  </div>
</div>
```

### 2. Modelo

Seu modelo precisa ter um método para agendar:

```ruby
# app/models/seu_modelo.rb
def schedule_appointment!(scheduled_datetime, user)
  update!(
    scheduled_at: scheduled_datetime,
    status: :scheduled,
    scheduled_by: user
  )
end
```

### 3. JavaScript Controller

O sistema já inclui o `AgendaSchedulerController` que gerencia toda a lógica de seleção em cascata. Certifique-se de que está registrado:

```javascript
// app/frontend/javascript/controllers/application.js
import AgendaSchedulerController from '../../../javascript/controllers/agenda_scheduler_controller';

application.register('agenda-scheduler', AgendaSchedulerController);
```

## Exemplo Prático: Portal Intakes

O sistema já está integrado com Portal Intakes como exemplo. Para ver como funciona:

1. Acesse **Admin > Portal Intakes**
2. Clique em **"Agendar"** em qualquer entrada
3. Clique em **"Agendar com Agenda"**
4. Siga o fluxo de seleção:
   - Selecione a agenda
   - Escolha o profissional
   - Defina a data
   - Escolha o horário
   - Confirme o agendamento

## Tipos de Serviço Disponíveis

O sistema suporta os seguintes tipos de serviço:

- `:anamnese` - Para anamneses
- `:consulta` - Para consultas médicas
- `:atendimento` - Para atendimentos gerais
- `:reuniao` - Para reuniões
- `:outro` - Para outros tipos de serviço

## Status das Agendas

- **Rascunho**: Agenda em criação, não disponível para agendamentos
- **Ativa**: Agenda funcionando e disponível para agendamentos
- **Arquivada**: Agenda desativada, não disponível para novos agendamentos

## Configuração de Horários

As agendas suportam:

- **Duração do atendimento**: Tempo de cada consulta (ex: 50 minutos)
- **Intervalo entre consultas**: Tempo de preparação (ex: 10 minutos)
- **Horários por dia**: Configuração de dias da semana e períodos
- **Exceções**: Datas especiais ou feriados

## Troubleshooting

### Problema: Agendas não aparecem na lista
**Solução**: Verifique se a agenda está com status "Ativa" e tem profissionais vinculados.

### Problema: Horários não são gerados
**Solução**: Verifique se a agenda tem horários configurados para o dia selecionado.

### Problema: Formulário não submete
**Solução**: Verifique se todos os campos obrigatórios estão preenchidos e se o JavaScript está carregado.

### Problema: Erro "Missing target element"
**Solução**: Certifique-se de que o script com dados das agendas está dentro do formulário com `data-controller="agenda-scheduler"`.

## Próximos Passos

1. **Criar mais tipos de agenda** conforme necessário
2. **Implementar notificações** de agendamento
3. **Adicionar validações** de conflito de horários
4. **Criar relatórios** de agendamentos
5. **Implementar cancelamento** de agendamentos
