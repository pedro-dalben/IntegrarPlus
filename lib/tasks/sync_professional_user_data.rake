# frozen_string_literal: true

namespace :data do
  desc "Sincronizar dados entre Professional e User"
  task sync_professional_user: :environment do
    puts "=== Sincronização Professional <-> User ==="
    puts

    professionals_updated = 0
    users_created = 0
    errors = []

    Professional.includes(:user).find_each do |professional|
      begin
        if professional.user.present?
          # Sincronizar dados existentes
          user_updates = {}

          if professional.user.name != professional.full_name
            user_updates[:name] = professional.full_name
          end

          if professional.user.email != professional.email
            user_updates[:email] = professional.email
          end

          if user_updates.any?
            professional.user.update!(user_updates)
            puts "✅ Usuário #{professional.user.id} atualizado: #{user_updates}"
            professionals_updated += 1
          end
        else
          # Criar usuário se não existir e profissional estiver ativo
          if professional.active?
            user = professional.create_user_automatically
            if user
              puts "✅ Usuário criado para profissional #{professional.full_name} (#{professional.email})"
              users_created += 1
            end
          else
            puts "⏭️  Profissional #{professional.full_name} inativo - usuário não criado"
          end
        end
      rescue => e
        error_msg = "❌ Erro com profissional #{professional.id} (#{professional.full_name}): #{e.message}"
        puts error_msg
        errors << error_msg
      end
    end

    puts
    puts "=== Resumo ==="
    puts "Usuários atualizados: #{professionals_updated}"
    puts "Usuários criados: #{users_created}"
    puts "Erros: #{errors.count}"

    if errors.any?
      puts
      puts "=== Erros Detalhados ==="
      errors.each { |error| puts error }
    end
  end

  desc "Verificar inconsistências entre Professional e User"
  task check_professional_user_consistency: :environment do
    puts "=== Verificação de Consistência Professional <-> User ==="
    puts

    inconsistencies = []

    Professional.includes(:user).where.not(user: nil).find_each do |professional|
      user = professional.user

      # Verificar nome
      if user.name != professional.full_name
        inconsistencies << {
          professional_id: professional.id,
          type: 'name_mismatch',
          professional_value: professional.full_name,
          user_value: user.name
        }
      end

      # Verificar email
      if user.email != professional.email
        inconsistencies << {
          professional_id: professional.id,
          type: 'email_mismatch',
          professional_value: professional.email,
          user_value: user.email
        }
      end
    end

    if inconsistencies.any?
      puts "❌ Encontradas #{inconsistencies.count} inconsistências:"
      puts

      inconsistencies.each do |inc|
        professional = Professional.find(inc[:professional_id])
        puts "Profissional: #{professional.full_name} (ID: #{inc[:professional_id]})"
        puts "  Tipo: #{inc[:type]}"
        puts "  Professional: #{inc[:professional_value]}"
        puts "  User: #{inc[:user_value]}"
        puts
      end

      puts "Execute 'rake data:sync_professional_user' para corrigir."
    else
      puts "✅ Nenhuma inconsistência encontrada!"
    end
  end
end
