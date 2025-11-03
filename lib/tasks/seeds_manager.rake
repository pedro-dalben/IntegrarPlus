# frozen_string_literal: true

module SeedsManager
  module_function

  def pending_production_seeds_file
    Rails.root.join('.pending_production_seeds')
  end

  def pending_production_seeds
    return [] unless File.exist?(pending_production_seeds_file)

    seeds = []
    File.readlines(pending_production_seeds_file).each do |line|
      line = line.strip
      next if line.empty? || line.start_with?('#')

      file_path = line.start_with?('/') ? line : File.expand_path(line, Rails.root)
      next unless File.exist?(file_path)

      seeds << {
        name: File.basename(file_path, '.rb'),
        file: file_path
      }
    end

    seeds.select { |s| File.exist?(s[:file]) }
  end

  def add_to_production_queue(seed_file)
    queue_file = pending_production_seeds_file
    seed_path = File.expand_path(seed_file, Rails.root)

    seeds = []
    seeds = File.readlines(queue_file).map(&:strip).reject(&:empty?) if File.exist?(queue_file)

    return if seeds.include?(seed_path)

    seeds << seed_path
    File.write(queue_file, "#{seeds.join("\n")}\n")
  end

  def remove_from_production_queue(seed_file)
    queue_file = pending_production_seeds_file
    return unless File.exist?(queue_file)

    seed_path = File.expand_path(seed_file, Rails.root)
    seeds = File.readlines(queue_file).map(&:strip).reject { |s| s == seed_path || s.empty? || s.start_with?('#') }

    if seeds.empty?
      FileUtils.rm_f(queue_file)
    else
      File.write(queue_file, "#{seeds.join("\n")}\n")
    end
  end

  def clear_production_queue
    queue_file = pending_production_seeds_file
    FileUtils.rm_f(queue_file)
  end
end

namespace :seeds do
  desc 'List pending production seeds'
  task list: :environment do
    pending_seeds = SeedsManager.pending_production_seeds
    if pending_seeds.empty?
      puts '✅ No pending production seeds'
    else
      puts "⚠️  Found #{pending_seeds.count} pending seed(s):"
      pending_seeds.each do |seed|
        puts "  - #{seed[:name]} (#{seed[:file]})"
      end
    end
  end

  desc 'Add seed to production queue (will run on next reload-vps)'
  task :add, [:seed_file] => :environment do |_t, args|
    seed_file = args[:seed_file]
    unless seed_file
      puts '❌ Usage: rails seeds:add[path/to/seed/file.rb]'
      exit 1
    end

    unless File.exist?(seed_file)
      puts "❌ Seed file not found: #{seed_file}"
      exit 1
    end

    SeedsManager.add_to_production_queue(seed_file)
    puts "✅ Added #{seed_file} to production seed queue"
    puts '   Will be executed on next reload-vps and removed if successful'
  end

  desc 'Remove seed from production queue'
  task :remove, [:seed_file] => :environment do |_t, args|
    seed_file = args[:seed_file]
    unless seed_file
      puts '❌ Usage: rails seeds:remove[path/to/seed/file.rb]'
      exit 1
    end

    SeedsManager.remove_from_production_queue(seed_file)
    puts "✅ Removed #{seed_file} from production seed queue"
  end

  desc 'Execute pending production seeds'
  task execute_pending: :environment do
    pending_seeds = SeedsManager.pending_production_seeds
    if pending_seeds.empty?
      puts '✅ No pending seeds to execute'
      next
    end

    puts "Executing #{pending_seeds.count} pending seed(s)..."
    executed = []
    failed = []

    pending_seeds.each do |seed|
      puts "\n▶️  Executing: #{seed[:name]} (#{seed[:file]})"
      load seed[:file]
      executed << seed
      puts "✅ Success: #{seed[:name]}"
    rescue StandardError => e
      failed << { seed: seed, error: e }
      puts "❌ Failed: #{seed[:name]} - #{e.message}"
      puts "   #{e.backtrace.first}"
    end

    if failed.any?
      puts "\n⚠️  #{failed.count} seed(s) failed. Not removing from queue."
      puts '   Fix errors and run again, or manually remove with: rails seeds:remove[FILE]'
      raise 'Seed execution failed'
    end

    executed.each do |seed|
      SeedsManager.remove_from_production_queue(seed[:file])
      puts "   Removed #{seed[:file]} from queue (execution successful)"
    end

    puts "\n✅ All #{executed.count} seed(s) executed successfully and removed from queue"
  end

  desc 'Clear all pending seeds (use with caution)'
  task clear: :environment do
    if SeedsManager.pending_production_seeds.any?
      SeedsManager.clear_production_queue
      puts '✅ Cleared all pending seeds from queue'
    else
      puts 'ℹ️  No pending seeds to clear'
    end
  end
end
