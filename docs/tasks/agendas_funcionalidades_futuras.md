# 📅 Sistema de Agendas - Funcionalidades Futuras

## 🎯 Visão Geral

Este documento descreve as funcionalidades futuras planejadas para o Sistema de Agendas da Clínica Integrar, organizadas por prioridade e complexidade de implementação. O sistema atual já possui a base funcional com wizard de criação, navegação entre steps e layout padronizado.

---

## 🚀 **FASE 1: Validação e Confiabilidade (Prioridade ALTA)**

### 1.1 Sistema de Validação Avançada

**Objetivo**: Implementar validações robustas para evitar conflitos e erros na criação de agendas.

#### Especificações Técnicas:

```ruby
# app/models/concerns/agenda_validations.rb
module AgendaValidations
  extend ActiveSupport::Concern
  
  included do
    validate :working_hours_format
    validate :no_overlapping_schedules
    validate :professional_availability
    validate :slot_duration_consistency
  end
  
  private
  
  def working_hours_format
    return unless working_hours.present?
    
    working_hours.each do |day, schedules|
      schedules.each do |schedule|
        unless valid_time_range?(schedule['start_time'], schedule['end_time'])
          errors.add(:working_hours, "Horários inválidos para #{day}")
        end
      end
    end
  end
  
  def no_overlapping_schedules
    # Validar que não há sobreposição de horários no mesmo dia
  end
  
  def professional_availability
    # Validar se profissionais estão disponíveis nos horários definidos
  end
end
```

#### Regras de Negócio:
- Horários de início devem ser anteriores aos de fim
- Não pode haver sobreposição de horários no mesmo dia
- Profissionais devem estar ativos e disponíveis
- Duração dos slots deve ser consistente com os horários

#### UX/UI:
- Validação em tempo real durante o preenchimento
- Mensagens de erro específicas e claras
- Indicadores visuais de campos inválidos
- Sugestões automáticas para correção

---

### 1.2 Sistema de Conflitos e Disponibilidade

**Objetivo**: Detectar e prevenir conflitos entre agendas e eventos existentes.

#### Especificações Técnicas:

```ruby
# app/services/agenda_conflict_service.rb
class AgendaConflictService
  def self.check_conflicts(agenda, professional, start_time, end_time)
    conflicts = []
    
    # Verificar conflitos com outras agendas
    conflicts += check_agenda_conflicts(agenda, professional, start_time, end_time)
    
    # Verificar conflitos com eventos existentes
    conflicts += check_event_conflicts(professional, start_time, end_time)
    
    # Verificar feriados e exceções
    conflicts += check_holiday_conflicts(start_time, end_time)
    
    conflicts
  end
  
  private
  
  def self.check_agenda_conflicts(agenda, professional, start_time, end_time)
    # Lógica para verificar conflitos com outras agendas
  end
  
  def self.check_event_conflicts(professional, start_time, end_time)
    # Lógica para verificar conflitos com eventos
  end
end
```

#### Regras de Negócio:
- Um profissional não pode ter duas agendas ativas no mesmo horário
- Verificar conflitos com eventos já agendados
- Considerar feriados e dias de folga
- Alertar sobre sobreposições parciais

#### UX/UI:
- Alertas visuais durante a criação
- Lista de conflitos detectados
- Opções para resolver conflitos automaticamente
- Preview de disponibilidade em tempo real

---

## 📊 **FASE 2: Dashboard e Métricas (Prioridade ALTA)**

### 2.1 Dashboard Executivo de Agendas

**Objetivo**: Fornecer visão geral das métricas e status das agendas.

#### Especificações Técnicas:

```erb
<!-- app/views/admin/agendas/dashboard.html.erb -->
<div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
  <div class="bg-white p-6 rounded-lg shadow border">
    <div class="flex items-center">
      <div class="p-2 bg-blue-100 rounded-lg">
        <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
        </svg>
      </div>
      <div class="ml-4">
        <h3 class="text-lg font-semibold text-gray-800">Agendas Ativas</h3>
        <p class="text-3xl font-bold text-blue-600"><%= @active_agendas_count %></p>
        <p class="text-sm text-gray-500">+<%= @agendas_growth %>% vs mês anterior</p>
      </div>
    </div>
  </div>
  
  <div class="bg-white p-6 rounded-lg shadow border">
    <div class="flex items-center">
      <div class="p-2 bg-green-100 rounded-lg">
        <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"/>
        </svg>
      </div>
      <div class="ml-4">
        <h3 class="text-lg font-semibold text-gray-800">Profissionais Ativos</h3>
        <p class="text-3xl font-bold text-green-600"><%= @active_professionals_count %></p>
        <p class="text-sm text-gray-500">Com agenda configurada</p>
      </div>
    </div>
  </div>
  
  <div class="bg-white p-6 rounded-lg shadow border">
    <div class="flex items-center">
      <div class="p-2 bg-purple-100 rounded-lg">
        <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
        </svg>
      </div>
      <div class="ml-4">
        <h3 class="text-lg font-semibold text-gray-800">Slots Disponíveis</h3>
        <p class="text-3xl font-bold text-purple-600"><%= @available_slots_count %></p>
        <p class="text-sm text-gray-500">Próximos 7 dias</p>
      </div>
    </div>
  </div>
  
  <div class="bg-white p-6 rounded-lg shadow border">
    <div class="flex items-center">
      <div class="p-2 bg-orange-100 rounded-lg">
        <svg class="w-6 h-6 text-orange-600" fill="none" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/>
        </svg>
      </div>
      <div class="ml-4">
        <h3 class="text-lg font-semibold text-gray-800">Taxa de Ocupação</h3>
        <p class="text-3xl font-bold text-orange-600"><%= @occupancy_rate %>%</p>
        <p class="text-sm text-gray-500">Média mensal</p>
      </div>
    </div>
  </div>
</div>
```

#### Métricas Incluídas:
- Total de agendas ativas
- Número de profissionais com agenda
- Slots disponíveis nos próximos dias
- Taxa de ocupação média
- Crescimento mensal
- Agendas com conflitos

#### UX/UI:
- Cards com métricas visuais
- Gráficos de tendência
- Filtros por período
- Exportação de dados

---

### 2.2 Gráficos e Visualizações

**Objetivo**: Fornecer visualizações gráficas das métricas de agenda.

#### Especificações Técnicas:

```javascript
// app/javascript/controllers/agenda_dashboard_controller.js
import { Controller } from "@hotwired/stimulus"
import Chart from 'chart.js/auto'

export default class extends Controller {
  static targets = ["occupancyChart", "utilizationChart", "trendsChart"]
  
  connect() {
    this.initializeCharts()
  }
  
  initializeCharts() {
    this.createOccupancyChart()
    this.createUtilizationChart()
    this.createTrendsChart()
  }
  
  createOccupancyChart() {
    new Chart(this.occupancyChartTarget, {
      type: 'doughnut',
      data: {
        labels: ['Ocupado', 'Disponível'],
        datasets: [{
          data: [this.data.get('occupied'), this.data.get('available')],
          backgroundColor: ['#ef4444', '#10b981']
        }]
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            position: 'bottom'
          }
        }
      }
    })
  }
}
```

#### Tipos de Gráficos:
- Gráfico de pizza: Ocupação vs Disponibilidade
- Gráfico de barras: Utilização por profissional
- Gráfico de linha: Tendências temporais
- Heatmap: Ocupação por horário/dia

---

## 🔔 **FASE 3: Notificações e Alertas (Prioridade MÉDIA)**

### 3.1 Sistema de Notificações Inteligentes

**Objetivo**: Notificar usuários sobre mudanças importantes nas agendas.

#### Especificações Técnicas:

```ruby
# app/models/concerns/agenda_notifications.rb
module AgendaNotifications
  extend ActiveSupport::Concern
  
  included do
    after_update :notify_schedule_changes
    after_create :notify_agenda_created
  end
  
  def notify_schedule_changes
    return unless saved_change_to_working_hours?
    
    professionals.each do |professional|
      AgendaNotificationMailer.schedule_changed(professional.user, self).deliver_later
    end
  end
  
  def notify_conflicts
    conflicts = AgendaConflictService.check_conflicts(self, professional, start_time, end_time)
    
    if conflicts.any?
      AgendaNotificationMailer.conflicts_detected(created_by, conflicts).deliver_later
    end
  end
  
  def notify_agenda_created
    AgendaNotificationMailer.agenda_created(created_by, self).deliver_later
  end
end
```

#### Tipos de Notificações:
- Mudanças na agenda
- Conflitos detectados
- Novas agendas criadas
- Agendas arquivadas
- Lembretes de manutenção

#### Canais de Notificação:
- Email
- Notificações in-app
- Push notifications (futuro)
- SMS (futuro)

---

### 3.2 Sistema de Alertas Proativos

**Objetivo**: Alertar sobre problemas potenciais antes que ocorram.

#### Especificações Técnicas:

```ruby
# app/services/agenda_alert_service.rb
class AgendaAlertService
  def self.check_alerts
    alerts = []
    
    alerts += check_low_occupancy
    alerts += check_conflicts
    alerts += check_inactive_agendas
    alerts += check_maintenance_needed
    
    alerts
  end
  
  private
  
  def self.check_low_occupancy
    # Alertar sobre agendas com baixa ocupação
  end
  
  def self.check_conflicts
    # Alertar sobre conflitos não resolvidos
  end
end
```

#### Tipos de Alertas:
- Baixa ocupação de agenda
- Conflitos não resolvidos
- Agendas inativas há muito tempo
- Necessidade de manutenção
- Profissionais sobrecarregados

---

## 📈 **FASE 4: Relatórios Avançados (Prioridade MÉDIA)**

### 4.1 Sistema de Relatórios Executivos

**Objetivo**: Gerar relatórios detalhados sobre o uso das agendas.

#### Especificações Técnicas:

```ruby
# app/controllers/admin/agenda_reports_controller.rb
class Admin::AgendaReportsController < Admin::BaseController
  before_action :ensure_can_view_reports
  
  def occupancy_report
    @report = AgendaOccupancyReport.new(params[:date_range], params[:agenda_ids])
    @data = @report.generate
    
    respond_to do |format|
      format.html
      format.xlsx { send_data @report.to_excel, filename: "relatorio_ocupacao_#{Date.current}.xlsx" }
      format.pdf { render pdf: "relatorio_ocupacao_#{Date.current}" }
    end
  end
  
  def professional_utilization
    @report = ProfessionalUtilizationReport.new(params[:professional_ids], params[:date_range])
    @data = @report.generate
  end
  
  def trends_analysis
    @report = AgendaTrendsReport.new(params[:period])
    @data = @report.generate
  end
  
  private
  
  def ensure_can_view_reports
    authorize :agenda_report, :view?
  end
end
```

#### Tipos de Relatórios:
- Relatório de Ocupação por Período
- Utilização por Profissional
- Análise de Tendências
- Relatório de Conflitos
- Relatório de Performance

#### Formatos de Exportação:
- Excel (.xlsx)
- PDF
- CSV
- JSON (para APIs)

---

### 4.2 Relatórios Personalizáveis

**Objetivo**: Permitir que usuários criem relatórios customizados.

#### Especificações Técnicas:

```ruby
# app/models/agenda_report_template.rb
class AgendaReportTemplate < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  
  validates :name, presence: true
  validates :query_params, presence: true
  
  def generate_report(date_range = nil)
    AgendaReportGenerator.new(self, date_range).generate
  end
end
```

#### Funcionalidades:
- Construtor visual de relatórios
- Filtros personalizáveis
- Agrupamentos customizados
- Agendamento de relatórios
- Compartilhamento de templates

---

## 🎨 **FASE 5: Interface e UX (Prioridade MÉDIA)**

### 5.1 Calendário Visual Interativo

**Objetivo**: Fornecer visualização clara das agendas em formato de calendário.

#### Especificações Técnicas:

```erb
<!-- app/views/admin/agendas/calendar.html.erb -->
<div class="calendar-container" data-controller="agenda-calendar">
  <div class="calendar-header flex justify-between items-center mb-6">
    <div class="flex items-center space-x-4">
      <button data-action="click->agenda-calendar#previousMonth" 
              class="p-2 rounded-lg border hover:bg-gray-50">
        <svg class="w-5 h-5" fill="none" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
        </svg>
      </button>
      <h2 data-agenda-calendar-target="monthYear" class="text-xl font-semibold">Janeiro 2025</h2>
      <button data-action="click->agenda-calendar#nextMonth"
              class="p-2 rounded-lg border hover:bg-gray-50">
        <svg class="w-5 h-5" fill="none" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
        </svg>
      </button>
    </div>
    
    <div class="flex items-center space-x-2">
      <select data-action="change->agenda-calendar#filterByAgenda" 
              class="border rounded-lg px-3 py-2">
        <option value="">Todas as agendas</option>
        <% @agendas.each do |agenda| %>
          <option value="<%= agenda.id %>"><%= agenda.name %></option>
        <% end %>
      </select>
      
      <button data-action="click->agenda-calendar#toggleView"
              class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
        <span data-agenda-calendar-target="viewToggle">Visualização Semanal</span>
      </button>
    </div>
  </div>
  
  <div class="calendar-grid bg-white rounded-lg border overflow-hidden" 
       data-agenda-calendar-target="grid">
    <!-- Grid do calendário será preenchido via JavaScript -->
  </div>
</div>
```

#### Funcionalidades:
- Visualização mensal/semanal/diária
- Filtros por agenda/profissional
- Cores diferentes por tipo de agenda
- Drag & drop para reorganização
- Zoom in/out para detalhes

---

### 5.2 Sistema de Templates de Agenda

**Objetivo**: Acelerar a criação de agendas com templates pré-definidos.

#### Especificações Técnicas:

```ruby
# app/models/agenda_template.rb
class AgendaTemplate < ApplicationRecord
  belongs_to :created_by, class_name: 'User'
  has_many :agendas, dependent: :nullify
  
  validates :name, presence: true
  validates :template_data, presence: true
  
  def apply_to_agenda(agenda)
    template_data.each do |key, value|
      agenda.send("#{key}=", value) if agenda.respond_to?("#{key}=")
    end
  end
  
  def self.create_from_agenda(agenda)
    create!(
      name: "Template baseado em #{agenda.name}",
      template_data: {
        service_type: agenda.service_type,
        default_visibility: agenda.default_visibility,
        slot_duration_minutes: agenda.slot_duration_minutes,
        buffer_minutes: agenda.buffer_minutes,
        working_hours: agenda.working_hours
      }
    )
  end
end
```

#### Tipos de Templates:
- Template de Consulta Padrão
- Template de Anamnese
- Template de Atendimento
- Template de Reunião
- Templates personalizados

---

## 🔧 **FASE 6: Integração e API (Prioridade BAIXA)**

### 6.1 API REST para Integração Externa

**Objetivo**: Permitir integração com sistemas externos.

#### Especificações Técnicas:

```ruby
# app/controllers/api/v1/agendas_controller.rb
class Api::V1::AgendasController < ApplicationController
  before_action :authenticate_api_user
  before_action :set_agenda, only: [:show, :update, :destroy]
  
  def index
    @agendas = Agenda.active.includes(:professionals, :unit)
    render json: @agendas, include: [:professionals, :unit]
  end
  
  def show
    render json: @agenda, include: [:professionals, :unit, :working_hours]
  end
  
  def available_slots
    @slots = AgendaSlotService.new(params[:agenda_id], params[:date]).available_slots
    render json: @slots
  end
  
  def create
    @agenda = Agenda.new(agenda_params)
    @agenda.created_by = current_user
    
    if @agenda.save
      render json: @agenda, status: :created
    else
      render json: { errors: @agenda.errors }, status: :unprocessable_entity
    end
  end
  
  private
  
  def authenticate_api_user
    # Implementar autenticação via token
  end
  
  def agenda_params
    params.require(:agenda).permit(:name, :service_type, :default_visibility, 
                                  :unit_id, :color_theme, :notes, :slot_duration_minutes, 
                                  :buffer_minutes, :working_hours, professional_ids: [])
  end
end
```

#### Endpoints da API:
- `GET /api/v1/agendas` - Listar agendas
- `GET /api/v1/agendas/:id` - Detalhes da agenda
- `POST /api/v1/agendas` - Criar agenda
- `PUT /api/v1/agendas/:id` - Atualizar agenda
- `DELETE /api/v1/agendas/:id` - Excluir agenda
- `GET /api/v1/agendas/:id/available_slots` - Slots disponíveis

---

### 6.2 Webhooks para Eventos

**Objetivo**: Notificar sistemas externos sobre mudanças nas agendas.

#### Especificações Técnicas:

```ruby
# app/services/webhook_service.rb
class WebhookService
  def self.notify_agenda_created(agenda)
    send_webhook('agenda.created', agenda)
  end
  
  def self.notify_agenda_updated(agenda)
    send_webhook('agenda.updated', agenda)
  end
  
  def self.notify_agenda_deleted(agenda)
    send_webhook('agenda.deleted', agenda)
  end
  
  private
  
  def self.send_webhook(event, agenda)
    webhook_urls = WebhookEndpoint.where(events: event).pluck(:url)
    
    webhook_urls.each do |url|
      WebhookJob.perform_later(url, event, agenda.to_json)
    end
  end
end
```

---

## 🛡️ **FASE 7: Segurança e Auditoria (Prioridade BAIXA)**

### 7.1 Sistema de Auditoria Completo

**Objetivo**: Rastrear todas as mudanças nas agendas para auditoria.

#### Especificações Técnicas:

```ruby
# app/models/concerns/agenda_audit.rb
module AgendaAudit
  extend ActiveSupport::Concern
  
  included do
    has_many :audit_logs, as: :auditable, dependent: :destroy
    after_create :log_creation
    after_update :log_changes
    after_destroy :log_deletion
  end
  
  private
  
  def log_creation
    create_audit_log('created', changes: attributes)
  end
  
  def log_changes
    return unless saved_changes.any?
    
    create_audit_log('updated', changes: saved_changes)
  end
  
  def log_deletion
    create_audit_log('deleted', changes: attributes)
  end
  
  def create_audit_log(action, changes: {})
    audit_logs.create!(
      action: action,
      changes: changes,
      user: Current.user,
      ip_address: Current.request&.remote_ip,
      user_agent: Current.request&.user_agent
    )
  end
end
```

---

### 7.2 Sistema de Backup e Restauração

**Objetivo**: Proteger dados das agendas com backups automáticos.

#### Especificações Técnicas:

```ruby
# app/services/agenda_backup_service.rb
class AgendaBackupService
  def self.create_backup
    backup_data = {
      agendas: Agenda.all.as_json,
      agenda_professionals: AgendaProfessional.all.as_json,
      created_at: Time.current
    }
    
    backup_file = "agenda_backup_#{Time.current.strftime('%Y%m%d_%H%M%S')}.json"
    backup_path = Rails.root.join('storage', 'backups', backup_file)
    
    File.write(backup_path, backup_data.to_json)
    
    # Enviar para armazenamento externo (S3, etc.)
    upload_to_external_storage(backup_path)
    
    backup_file
  end
  
  def self.restore_from_backup(backup_file)
    backup_path = Rails.root.join('storage', 'backups', backup_file)
    backup_data = JSON.parse(File.read(backup_path))
    
    ActiveRecord::Base.transaction do
      # Restaurar agendas
      backup_data['agendas'].each do |agenda_data|
        Agenda.create!(agenda_data.except('id', 'created_at', 'updated_at'))
      end
      
      # Restaurar relacionamentos
      backup_data['agenda_professionals'].each do |ap_data|
        AgendaProfessional.create!(ap_data.except('id', 'created_at', 'updated_at'))
      end
    end
  end
end
```

---

## 📋 **Cronograma de Implementação**

### **Semana 1-2: Fase 1 - Validação e Confiabilidade**
- [ ] Sistema de Validação Avançada
- [ ] Sistema de Conflitos e Disponibilidade
- [ ] Testes automatizados

### **Semana 3-4: Fase 2 - Dashboard e Métricas**
- [ ] Dashboard Executivo
- [ ] Gráficos e Visualizações
- [ ] Métricas em tempo real

### **Semana 5-6: Fase 3 - Notificações**
- [ ] Sistema de Notificações
- [ ] Alertas Proativos
- [ ] Configurações de notificação

### **Semana 7-8: Fase 4 - Relatórios**
- [ ] Relatórios Executivos
- [ ] Relatórios Personalizáveis
- [ ] Exportação de dados

### **Semana 9-10: Fase 5 - Interface**
- [ ] Calendário Visual
- [ ] Templates de Agenda
- [ ] Melhorias de UX

### **Semana 11-12: Fase 6-7 - Integração e Segurança**
- [ ] API REST
- [ ] Sistema de Auditoria
- [ ] Backup e Restauração

---

## 🎯 **Critérios de Sucesso**

### **Métricas de Performance:**
- Tempo de carregamento < 2 segundos
- 99.9% de disponibilidade
- Zero conflitos não detectados
- 95% de satisfação do usuário

### **Métricas de Negócio:**
- 30% de redução no tempo de criação de agendas
- 50% de redução em conflitos de horário
- 25% de aumento na utilização das agendas
- 90% de adoção das novas funcionalidades

---

## 🔄 **Processo de Desenvolvimento**

### **Metodologia:**
1. **Análise de Requisitos**: Detalhamento técnico de cada funcionalidade
2. **Prototipagem**: Criação de mockups e wireframes
3. **Desenvolvimento**: Implementação seguindo TDD
4. **Testes**: Testes automatizados e manuais
5. **Deploy**: Deploy incremental com rollback automático
6. **Monitoramento**: Acompanhamento de métricas e feedback

### **Ferramentas:**
- **Frontend**: Stimulus, Tailwind CSS, Chart.js
- **Backend**: Ruby on Rails, Sidekiq, Redis
- **Testes**: RSpec, Capybara, Jest
- **Monitoramento**: Sentry, New Relic
- **CI/CD**: GitHub Actions

---

## 📝 **Conclusão**

Este documento serve como roadmap completo para a evolução do Sistema de Agendas. As funcionalidades estão organizadas por prioridade, com foco inicial em validação, confiabilidade e métricas que impactam diretamente a experiência do usuário.

A implementação deve seguir uma abordagem incremental, com entregas semanais e feedback contínuo dos usuários para garantir que as funcionalidades atendam às necessidades reais da clínica.

**Próximo passo recomendado**: Iniciar com a Fase 1 (Validação e Confiabilidade) para estabelecer uma base sólida antes de implementar funcionalidades mais complexas.
