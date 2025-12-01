# frozen_string_literal: true

namespace :performance do
  desc 'Check for N+1 queries using Bullet'
  task check_n_plus_one: :environment do
    unless Rails.env.development?
      puts '❌ Esta task deve rodar apenas em development'
      exit 1
    end

    unless defined?(Bullet)
      puts '❌ Bullet gem não está instalada'
      exit 1
    end

    puts '🔍 Iniciando verificação de N+1 queries...'
    puts '━' * 70
    puts ''

    Bullet.enable = true
    Bullet.raise = false
    Bullet.bullet_logger = true

    n_plus_one_found = false
    routes_to_test = []

    # Rotas principais do Admin
    routes_to_test << { name: 'Dashboard', path: '/admin' }
    routes_to_test << { name: 'Beneficiaries', path: '/admin/beneficiaries' }
    routes_to_test << { name: 'Groups', path: '/admin/groups' }
    routes_to_test << { name: 'Anamneses', path: '/admin/anamneses' }
    routes_to_test << { name: 'Professionals', path: '/admin/professionals' }
    routes_to_test << { name: 'Agendas', path: '/admin/agendas' }
    routes_to_test << { name: 'Workspace', path: '/admin/workspace' }
    routes_to_test << { name: 'Documents', path: '/admin/documents' }
    routes_to_test << { name: 'Flow Charts', path: '/admin/flow_charts' }
    routes_to_test << { name: 'Notifications', path: '/admin/notifications' }

    routes_to_test.each do |route|
      print "  📄 Testando #{route[:name].ljust(20)}"

      begin
        # Simular requisição
        Bullet.start_request

        case route[:path]
        when '/admin'
          # Dashboard
          Beneficiary.count
        when '/admin/beneficiaries'
          beneficiaries = Beneficiary.includes(:anamneses, :portal_intake).limit(20)
          beneficiaries.each do |b|
            b.name
            b.status_label
          end
        when '/admin/groups'
          groups = Group.includes(:permissions, :group_permissions, :users).limit(20)
          groups.each do |g|
            g.permissions.count
            g.users.count
          end
        when '/admin/anamneses'
          anamneses = Anamnesis.includes(:beneficiary, :professional, :portal_intake).limit(20)
          anamneses.each do |a|
            a.beneficiary.name
            a.professional&.full_name
          end
        when '/admin/professionals'
          professionals = Professional.includes(:user, :groups, :specialities, :specializations,
                                                :contract_type).limit(20)
          professionals.each do |p|
            p.user.email
            p.groups.count
          end
        when '/admin/agendas'
          agendas = Agenda.includes(:unit, :created_by, :professionals).limit(20)
          agendas.each do |a|
            a.unit&.name
            a.professionals.count
          end
        when '/admin/workspace'
          documents = Document.includes(:author, :document_versions,
                                        :document_responsibles).where.not(status: 'liberado').limit(20)
          documents.each do |d|
            d.author&.full_name
            d.document_responsibles.count
          end
        when '/admin/documents'
          documents = Document.includes(:author, :document_versions).limit(20)
          documents.each { |d| d.author&.full_name }
        when '/admin/flow_charts'
          flow_charts = FlowChart.includes(:created_by, :current_version).limit(20)
          flow_charts.each { |f| f.created_by&.full_name }
        when '/admin/notifications'
          # Apenas contar
          Notification.count
        end

        # Verificar se Bullet detectou problemas
        Bullet.end_request

        if Bullet.notification?
          puts ' ❌ Problema detectado!'
          n_plus_one_found = true

          if Bullet.warnings.any?
            Bullet.warnings.each do |warning|
              puts "    ⚠️  #{warning}"
            end
          end

          if Bullet.collected_notifications.respond_to?(:each)
            Bullet.collected_notifications.each do |notification|
              next unless notification.respond_to?(:base_class) && notification.respond_to?(:associations)

              case notification.class.name
              when /NPlusOneQuery/
                puts "       💡 Adicione: .includes([#{notification.associations.map { |a| ":#{a}" }.join(', ')}])"
              when /UnusedEagerLoading/
                puts "       💡 Remova: .includes([#{notification.associations.map { |a| ":#{a}" }.join(', ')}])"
              when /CounterCache/
                puts '       💡 Considere adicionar counter cache'
              end
            end
          end
        else
          puts ' ✅ OK'
        end
      rescue StandardError => e
        puts " ⚠️  Erro: #{e.message}"
      end
    end

    puts ''
    puts '━' * 70

    if n_plus_one_found
      puts '❌ N+1 queries detectados!'
      puts ''
      puts '💡 Soluções:'
      puts '  1. Adicione includes() aos controllers'
      puts '  2. Use eager_load() para associações complexas'
      puts '  3. Verifique docs/N+1_QUERIES_FIX.md para guia'
      puts ''
      puts '📝 Log completo em: log/bullet.log'
      exit 1
    else
      puts '✅ Nenhum N+1 query detectado!'
      puts '🎉 Performance está otimizada!'
      exit 0
    end
  end

  desc 'Analisa controllers e sugere includes'
  task suggest_includes: :environment do
    puts '🔍 Analisando controllers e views...'
    puts '━' * 70
    puts ''

    controller_paths = Rails.root.glob('app/controllers/admin/**/*.rb')

    controller_paths.each do |path|
      file_name = File.basename(path, '.rb')
      next if file_name.ends_with?('_controller') == false

      model_name = file_name.gsub('_controller', '').singularize.camelize

      begin
        model = model_name.constantize
        associations = model.reflect_on_all_associations.map(&:name)

        if associations.any?
          puts "📋 #{model_name}:"
          puts "   Associações disponíveis: #{associations.join(', ')}"
          puts ''
        end
      rescue StandardError
        next
      end
    end

    puts '━' * 70
    puts '💡 Use estas associações em .includes() nos controllers'
  end
end
