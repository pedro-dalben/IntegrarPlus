# frozen_string_literal: true

# Teste de Validação de Especializações
# Execute este arquivo no console do Rails: rails console
# load 'test_specialization_validation.rb'

puts '=== Teste de Validação de Especializações ==='

# Verificar se os modelos estão carregados
begin
  puts 'Verificando modelos...'
  puts "Professional: #{Professional}"
  puts "Speciality: #{Speciality}"
  puts "Specialization: #{Specialization}"
  puts '✅ Modelos carregados com sucesso'
rescue StandardError => e
  puts "❌ Erro ao carregar modelos: #{e.message}"
  exit
end

# Verificar relacionamentos
puts "\n=== Verificando Relacionamentos ==="

professional = Professional.new
puts "Professional.new: #{professional.class}"

# Verificar se os métodos de relacionamento existem
puts "\nMétodos de relacionamento:"
puts "has_specialities? #{professional.respond_to?(:specialities)}"
puts "has_specializations? #{professional.respond_to?(:specializations)}"
puts "has_speciality_ids? #{professional.respond_to?(:speciality_ids)}"
puts "has_specialization_ids? #{professional.respond_to?(:specialization_ids)}"

# Verificar se há dados para testar
puts "\n=== Verificando Dados Disponíveis ==="

specialities_count = Speciality.count
specializations_count = Specialization.count

puts "Especialidades disponíveis: #{specialities_count}"
puts "Especializações disponíveis: #{specializations_count}"

if specialities_count.zero?
  puts '⚠️ Nenhuma especialidade encontrada. Criando dados de teste...'

  # Criar especialidades de teste
  Speciality.create!(name: 'Cardiologia')
  Speciality.create!(name: 'Neurologia')
  puts '✅ Especialidades de teste criadas'
else
  puts '✅ Dados suficientes para teste'
end

if specializations_count.zero?
  puts '⚠️ Nenhuma especialização encontrada. Criando dados de teste...'

  # Criar especializações de teste
  spec1 = Specialization.create!(name: 'Cardiologia Intervencionista')
  spec2 = Specialization.create!(name: 'Neurocirurgia')

  # Associar especializações com especialidades
  spec1.specialities << Speciality.find_by(name: 'Cardiologia') if Speciality.find_by(name: 'Cardiologia')
  spec2.specialities << Speciality.find_by(name: 'Neurologia') if Speciality.find_by(name: 'Neurologia')

  puts '✅ Especializações de teste criadas'
else
  puts '✅ Dados suficientes para teste'
end

# Testar validação
puts "\n=== Testando Validação ==="

begin
  # Criar profissional com dados válidos
  puts 'Testando validação com dados válidos...'

  valid_professional = Professional.new(
    full_name: 'Dr. Teste',
    email: 'teste@exemplo.com',
    cpf: '123.456.789-00',
    active: true
  )

  # Adicionar especialidades válidas
  valid_specialities = Speciality.limit(2)
  valid_professional.speciality_ids = valid_specialities.pluck(:id)

  # Adicionar especializações que pertencem às especialidades selecionadas
  valid_specializations = []
  valid_specialities.each do |speciality|
    specializations_for_speciality = Specialization.joins(:specialities).where(specialities: { id: speciality.id }).limit(1)
    valid_specializations.concat(specializations_for_speciality)
  end

  if valid_specializations.any?
    valid_professional.specialization_ids = valid_specializations.pluck(:id)
    puts "Especialidades selecionadas: #{valid_professional.speciality_ids}"
    puts "Especializações selecionadas: #{valid_professional.specialization_ids}"

    # Validar
    if valid_professional.valid?
      puts '✅ Validação passou com dados válidos'
    else
      puts '❌ Validação falhou com dados válidos:'
      puts valid_professional.errors.full_messages
    end
  else
    puts '⚠️ Nenhuma especialização válida encontrada para teste'
  end
rescue StandardError => e
  puts "❌ Erro ao testar validação válida: #{e.message}"
  puts e.backtrace.first(5)
end

# Testar validação com dados inválidos
puts "\nTestando validação com dados inválidos..."

begin
  invalid_professional = Professional.new(
    full_name: 'Dr. Inválido',
    email: 'invalido@exemplo.com',
    cpf: '987.654.321-00',
    active: true
  )

  # Adicionar especialidades
  invalid_professional.speciality_ids = [Speciality.first.id] if Speciality.any?

  # Adicionar especialização que não pertence às especialidades selecionadas
  if Specialization.any?
    all_specializations = Specialization.all
    selected_specialities = invalid_professional.speciality_ids

    # Encontrar especialização que não pertence às especialidades selecionadas
    invalid_specialization = all_specializations.find do |spec|
      spec_speciality_ids = spec.specialities.pluck(:id)
      !spec_speciality_ids.intersect?(selected_specialities)
    end

    if invalid_specialization
      invalid_professional.specialization_ids = [invalid_specialization.id]
      puts "Especialidades selecionadas: #{invalid_professional.speciality_ids}"
      puts "Especialização inválida selecionada: #{invalid_specialization.name}"

      # Validar
      if invalid_professional.valid?
        puts '⚠️ Validação passou quando deveria falhar'
      else
        puts '✅ Validação falhou corretamente com dados inválidos:'
        puts invalid_professional.errors.full_messages
      end
    else
      puts '⚠️ Não foi possível encontrar especialização inválida para teste'
    end
  end
rescue StandardError => e
  puts "❌ Erro ao testar validação inválida: #{e.message}"
  puts e.backtrace.first(5)
end

puts "\n=== Teste Concluído ==="
puts 'Verifique os logs do Rails para mais detalhes sobre a validação.'
