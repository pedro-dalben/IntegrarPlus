# frozen_string_literal: true

namespace :professionals do
  desc 'Sincronizar grupos dos profissionais com seus usuários'
  task sync_groups: :environment do
    puts 'Iniciando sincronização de grupos dos profissionais...'

    professionals_with_groups = Professional.joins(:groups).includes(:user, :groups)

    puts "Encontrados #{professionals_with_groups.count} profissionais com grupos"

    professionals_with_groups.each do |professional|
      if professional.user.present?
        puts "Sincronizando grupos para profissional: #{professional.full_name} (#{professional.email})"

        # Remover grupos que não estão mais associados ao profissional
        professional.user.memberships.where.not(group: professional.groups).destroy_all

        # Adicionar grupos que estão associados ao profissional mas não ao usuário
        professional.groups.each do |group|
          membership = professional.user.memberships.find_or_create_by!(group: group)
          puts "  - Grupo '#{group.name}' #{membership.persisted? ? 'já associado' : 'associado'}"
        end

        puts "  ✓ Sincronização concluída para #{professional.full_name}"
      else
        puts "⚠ Profissional #{professional.full_name} não possui usuário associado"
      end
    end

    puts "\nSincronização concluída!"
  end
end
