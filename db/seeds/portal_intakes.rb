# frozen_string_literal: true

Rails.logger.debug '🏥 Criando dados de exemplo para Portal Intakes...'

# Verificar se existem external_users (operadoras)
if ExternalUser.none?
  Rails.logger.debug '⚠️  Nenhuma operadora encontrada. Execute seeds/external_users.rb primeiro.'
  return
end

# Operadoras existentes
operadoras = ExternalUser.active.limit(3)

if operadoras.empty?
  Rails.logger.debug '⚠️  Nenhuma operadora ativa encontrada.'
  return
end

# Dados de exemplo para entradas do portal
portal_intakes_data = [
  {
    beneficiary_name: 'João Silva dos Santos',
    plan_name: 'Plano Saúde Premium',
    card_code: 'PSP123456789',
    status: 'aguardando_agendamento_anamnese',
    requested_at: 2.days.ago,
    anamnesis_scheduled_on: nil
  },
  {
    beneficiary_name: 'Maria Oliveira Costa',
    plan_name: 'Plano Família Completo',
    card_code: 'PFC987654321',
    status: 'aguardando_anamnese',
    requested_at: 5.days.ago,
    anamnesis_scheduled_on: 2.days.from_now
  },
  {
    beneficiary_name: 'Carlos Eduardo Pereira',
    plan_name: 'Plano Executivo',
    card_code: 'PEX456789123',
    status: 'anamnese_concluida',
    requested_at: 1.week.ago,
    anamnesis_scheduled_on: 3.days.ago
  },
  {
    beneficiary_name: 'Ana Paula Rodrigues',
    plan_name: 'Plano Básico Nacional',
    card_code: 'PBN789123456',
    status: 'aguardando_agendamento_anamnese',
    requested_at: 1.day.ago,
    anamnesis_scheduled_on: nil
  },
  {
    beneficiary_name: 'Roberto Almeida Lima',
    plan_name: 'Plano Corporate Plus',
    card_code: 'PCP321654987',
    status: 'aguardando_anamnese',
    requested_at: 4.days.ago,
    anamnesis_scheduled_on: 1.day.from_now
  },
  {
    beneficiary_name: 'Fernanda Santos Ribeiro',
    plan_name: 'Plano Familiar Essential',
    card_code: 'PFE654987321',
    status: 'aguardando_agendamento_anamnese',
    requested_at: 3.hours.ago,
    anamnesis_scheduled_on: nil
  },
  {
    beneficiary_name: 'Lucas Fernandes Souza',
    plan_name: 'Plano Gold Premium',
    card_code: 'PGP147258369',
    status: 'anamnese_concluida',
    requested_at: 10.days.ago,
    anamnesis_scheduled_on: 7.days.ago
  },
  {
    beneficiary_name: 'Patricia Moura Silva',
    plan_name: 'Plano Master Health',
    card_code: 'PMH369258147',
    status: 'aguardando_anamnese',
    requested_at: 6.days.ago,
    anamnesis_scheduled_on: 3.days.from_now
  }
]

portal_intakes_data.each_with_index do |intake_data, index|
  # Distribui as entradas entre as operadoras
  operadora = operadoras[index % operadoras.count]

  # Criar apenas se não existir
  portal_intake = PortalIntake.find_or_initialize_by(
    operator: operadora,
    beneficiary_name: intake_data[:beneficiary_name],
    card_code: intake_data[:card_code]
  )

  next if portal_intake.persisted?

  portal_intake.assign_attributes(
    plan_name: intake_data[:plan_name],
    status: intake_data[:status],
    requested_at: intake_data[:requested_at],
    anamnesis_scheduled_on: intake_data[:anamnesis_scheduled_on]
  )

  if portal_intake.save
    Rails.logger.debug { "  ✅ Entrada criada: #{portal_intake.beneficiary_name} (#{operadora.company_name})" }

    # Para entradas que já foram agendadas, criar evento de agendamento
    if portal_intake.aguardando_anamnese? || portal_intake.anamnese_concluida?
      portal_intake.journey_events.create!(
        event_type: 'scheduled_anamnesis',
        metadata: {
          admin_name: 'Sistema (Seed)',
          scheduled_on: portal_intake.anamnesis_scheduled_on,
          from: 'aguardando_agendamento_anamnese',
          to: 'aguardando_anamnese'
        }
      )
    end

    # Para entradas concluídas, criar evento de conclusão
    if portal_intake.anamnese_concluida?
      portal_intake.journey_events.create!(
        event_type: 'finished_anamnesis',
        metadata: {
          admin_name: 'Sistema (Seed)',
          from: 'aguardando_anamnese',
          to: 'anamnese_concluida'
        }
      )
    end
  else
    Rails.logger.error "  ❌ Erro ao criar entrada: #{portal_intake.errors.full_messages.join(', ')}"
  end
end

Rails.logger.debug '✅ Portal Intakes criados com sucesso!'

# Estatísticas
total_intakes = PortalIntake.count
aguardando_agendamento = PortalIntake.aguardando_agendamento_anamnese.count
aguardando_anamnese = PortalIntake.aguardando_anamnese.count
concluidas = PortalIntake.anamnese_concluida.count

Rails.logger.debug "\n📊 Estatísticas das Entradas do Portal:"
Rails.logger.debug { "  Total de entradas: #{total_intakes}" }
Rails.logger.debug { "  Aguardando agendamento: #{aguardando_agendamento}" }
Rails.logger.debug { "  Aguardando anamnese: #{aguardando_anamnese}" }
Rails.logger.debug { "  Concluídas: #{concluidas}" }

operadoras.each do |operadora|
  count = operadora.portal_intakes.count
  Rails.logger.debug { "  #{operadora.company_name}: #{count} entradas" }
end
