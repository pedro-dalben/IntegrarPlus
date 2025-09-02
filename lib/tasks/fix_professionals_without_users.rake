# frozen_string_literal: true

namespace :professionals do
  desc 'Criar usuários para profissionais que não possuem usuário associado'
  task create_missing_users: :environment do
    puts '=== Criando Usuários para Profissionais sem Usuário ==='
    puts

    # Encontrar profissionais sem usuário
    professionals_without_user = Professional.where(user: nil)

    puts "📊 Total de profissionais sem usuário: #{professionals_without_user.count}"
    puts

    if professionals_without_user.none?
      puts '✅ Todos os profissionais já possuem usuário associado!'
      exit 0
    end

    # Separar por status ativo/inativo
    active_professionals = professionals_without_user.where(active: true)
    inactive_professionals = professionals_without_user.where(active: false)

    puts "📋 Profissionais ativos sem usuário: #{active_professionals.count}"
    puts "📋 Profissionais inativos sem usuário: #{inactive_professionals.count}"
    puts

    users_created = 0
    users_skipped = 0
    errors = []

    # Processar profissionais ativos primeiro
    puts '🔄 Processando profissionais ATIVOS...'
    active_professionals.find_each do |professional|
      # Criar usuário diretamente
      temp_password = SecureRandom.hex(12)
      user = User.create!(
        name: professional.full_name,
        email: professional.email,
        password: temp_password,
        password_confirmation: temp_password
      )

      # Associar ao profissional
      professional.update_column(:user_id, user.id)

      # Associar grupos do profissional ao usuário
      professional.groups.each do |group|
        user.memberships.create!(group: group)
      end

      puts "✅ Usuário criado para #{professional.full_name} (#{professional.email})"
      users_created += 1
    rescue StandardError => e
      error_msg = "Erro ao criar usuário para profissional #{professional.id} (#{professional.full_name}): #{e.message}"
      puts "❌ #{error_msg}"
      errors << error_msg
    end

    # Perguntar sobre profissionais inativos
    if inactive_professionals.any?
      puts
      puts "⚠️  Encontrados #{inactive_professionals.count} profissionais INATIVOS sem usuário."
      puts '   Profissionais inativos normalmente não precisam de usuário.'
      puts '   Deseja criar usuários para profissionais inativos? (s/N): '

      # Em ambiente de produção, não perguntar - apenas logar
      if Rails.env.production?
        puts '   Ambiente de produção - pulando profissionais inativos'
        users_skipped = inactive_professionals.count
      else
        # Em desenvolvimento, perguntar
        response = $stdin.gets.chomp.downcase
        if %w[s sim].include?(response)
          puts
          puts '🔄 Processando profissionais INATIVOS...'
          inactive_professionals.find_each do |professional|
            # Criar usuário diretamente
            temp_password = SecureRandom.hex(12)
            user = User.create!(
              name: professional.full_name,
              email: professional.email,
              password: temp_password,
              password_confirmation: temp_password
            )

            # Associar ao profissional
            professional.update_column(:user_id, user.id)

            # Associar grupos do profissional ao usuário
            professional.groups.each do |group|
              user.memberships.create!(group: group)
            end

            puts "✅ Usuário criado para #{professional.full_name} (#{professional.email}) - INATIVO"
            users_created += 1
          rescue StandardError => e
            error_msg = "Erro ao criar usuário para profissional inativo #{professional.id} (#{professional.full_name}): #{e.message}"
            puts "❌ #{error_msg}"
            errors << error_msg
          end
        else
          puts '   Pulando profissionais inativos'
          users_skipped = inactive_professionals.count
        end
      end
    end

    puts
    puts '=== Resumo ==='
    puts "✅ Usuários criados: #{users_created}"
    puts "⏭️  Profissionais pulados: #{users_skipped}"
    puts "❌ Erros: #{errors.count}"

    if errors.any?
      puts
      puts '=== Erros Detalhados ==='
      errors.each { |error| puts "  • #{error}" }
    end

    puts
    puts '=== Verificação Final ==='
    remaining_without_user = Professional.where(user: nil).count
    puts "Profissionais sem usuário restantes: #{remaining_without_user}"

    if remaining_without_user.zero?
      puts '🎉 Todos os profissionais agora possuem usuário!'
    else
      puts "⚠️  Ainda existem #{remaining_without_user} profissionais sem usuário"
    end
  end

  desc 'Listar profissionais sem usuário'
  task list_without_users: :environment do
    puts '=== Profissionais sem Usuário ==='
    puts

    professionals_without_user = Professional.where(user: nil)

    if professionals_without_user.none?
      puts '✅ Todos os profissionais possuem usuário!'
      exit 0
    end

    puts "Total: #{professionals_without_user.count} profissionais"
    puts

    professionals_without_user.order(:active, :full_name).each do |professional|
      status = professional.active? ? '🟢 ATIVO' : '🔴 INATIVO'
      puts "#{status} | #{professional.full_name} (#{professional.email}) | ID: #{professional.id}"
    end

    puts
    puts "Execute 'rake professionals:create_missing_users' para criar usuários"
  end

  desc 'Verificar status dos usuários dos profissionais'
  task check_user_status: :environment do
    puts '=== Status dos Usuários dos Profissionais ==='
    puts

    total_professionals = Professional.count
    professionals_with_user = Professional.where.not(user: nil).count
    professionals_without_user = Professional.where(user: nil).count
    active_professionals_without_user = Professional.where(user: nil, active: true).count

    puts '📊 Estatísticas:'
    puts "   Total de profissionais: #{total_professionals}"
    puts "   Com usuário: #{professionals_with_user}"
    puts "   Sem usuário: #{professionals_without_user}"
    puts "   Ativos sem usuário: #{active_professionals_without_user}"
    puts

    if active_professionals_without_user.positive?
      puts "⚠️  ATENÇÃO: #{active_professionals_without_user} profissionais ativos não possuem usuário!"
      puts "   Execute 'rake professionals:create_missing_users' para corrigir"
    else
      puts '✅ Todos os profissionais ativos possuem usuário!'
    end

    puts
    puts "Execute 'rake professionals:list_without_users' para ver detalhes"
  end
end
