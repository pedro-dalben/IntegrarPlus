# frozen_string_literal: true

namespace :meilisearch do
  desc 'Index all data in Meilisearch'
  task index: :environment do
    puts 'Indexing Professional data...'
    Professional.reindex!
    puts '✓ Professionals indexed'

    puts 'Indexing Speciality data...'
    Speciality.reindex!
    puts '✓ Specialities indexed'

    puts 'Indexing ContractType data...'
    ContractType.reindex!
    puts '✓ ContractTypes indexed'

    puts 'Indexing Document data...'
    Document.reindex!
    puts '✓ Documents indexed'

    puts 'All data indexed successfully!'
  end

  desc 'Clear all Meilisearch indexes'
  task clear: :environment do
    puts 'Clearing Professional index...'
    Professional.clear_index!
    puts '✓ Professionals cleared'

    puts 'Clearing Speciality index...'
    Speciality.clear_index!
    puts '✓ Specialities cleared'

    puts 'Clearing ContractType index...'
    ContractType.clear_index!
    puts '✓ ContractTypes cleared'

    puts 'Clearing Document index...'
    Document.clear_index!
    puts '✓ Documents cleared'

    puts 'All indexes cleared successfully!'
  end

  desc 'Reset all Meilisearch indexes (clear + index)'
  task reset: :environment do
    puts 'Resetting all Meilisearch indexes...'
    Rake::Task['meilisearch:clear'].invoke
    Rake::Task['meilisearch:index'].invoke
    puts 'All indexes reset successfully!'
  end
end
