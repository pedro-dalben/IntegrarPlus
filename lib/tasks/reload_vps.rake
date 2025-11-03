# frozen_string_literal: true

namespace :deploy do
  desc 'Reload VPS (run migrations, execute pending seeds)'
  task reload_vps: :environment do
    puts '🚀 Starting VPS reload process...'

    puts "\n1️⃣  Checking for pending migrations..."
    pending_migrations = ActiveRecord::Base.connection.migration_context.pending_migrations
    if pending_migrations.any?
      puts "   Found #{pending_migrations.count} pending migration(s)"
    else
      puts '   ✅ No pending migrations'
    end

    puts "\n2️⃣  Executing pending production seeds..."
    begin
      Rake::Task['seeds:execute_pending'].invoke
    rescue StandardError => e
      puts "\n❌ Seed execution failed: #{e.message}"
      puts '   Fix errors and run: rails seeds:execute_pending'
      exit 1
    end

    if pending_migrations.any?
      puts "\n3️⃣  Running migrations..."
      Rake::Task['db:migrate'].invoke
    else
      puts "\n3️⃣  No migrations to run"
    end

    puts "\n✅ VPS reload completed!"
    puts "\nNext steps:"
    puts '  - Verify application is running correctly'
    puts '  - Check logs for any errors'
    puts '  - To check pending seeds: rails seeds:list'
  end

  desc 'Pre-reload VPS checklist (run before reload-vps)'
  task pre_reload_check: :environment do
    puts '📋 Pre-reload VPS Checklist'
    puts ''

    pending_migrations = ActiveRecord::Base.connection.migration_context.pending_migrations
    pending_seeds = SeedsManager.pending_production_seeds

    puts "\n📊 Summary:"
    puts "  - Pending migrations: #{pending_migrations.count}"
    puts "  - Pending seeds: #{pending_seeds.count}"

    if pending_seeds.any?
      puts "\n📝 Pending seeds:"
      pending_seeds.each do |seed|
        puts "    - #{seed[:name]} (#{seed[:file]})"
      end
    end

    if pending_migrations.empty? && pending_seeds.empty?
      puts "\n✅ Ready for reload!"
    else
      puts "\n⚠️  Review pending items before proceeding"
    end
  end
end
