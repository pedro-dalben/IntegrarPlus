# frozen_string_literal: true

namespace :chat_v2 do
  desc 'Verify indexes integrity'
  task verify_indexes: :environment do
    puts 'Verifying chat V2 indexes...'

    issues = []

    duplicate_messages = ActiveRecord::Base.connection.execute(<<-SQL.squish)
      SELECT conversation_id, message_number, COUNT(*) as count
      FROM chat_messages
      GROUP BY conversation_id, message_number
      HAVING COUNT(*) > 1
      LIMIT 50
    SQL

    if duplicate_messages.any?
      puts '⚠️  Found duplicate message_numbers:'
      duplicate_messages.each do |row|
        puts "  Conversation #{row['conversation_id']}, message_number #{row['message_number']}: #{row['count']} duplicates"
      end
      issues << 'duplicate_message_numbers'
    else
      puts '✓ No duplicate message_numbers found'
    end

    duplicate_participations = ActiveRecord::Base.connection.execute(<<-SQL.squish)
      SELECT conversation_id, participant_type, participant_id, COUNT(*) as count
      FROM conversation_participations
      WHERE left_at IS NULL
      GROUP BY conversation_id, participant_type, participant_id
      HAVING COUNT(*) > 1
      LIMIT 50
    SQL

    if duplicate_participations.any?
      puts '⚠️  Found duplicate active participations:'
      duplicate_participations.each do |row|
        puts "  Conversation #{row['conversation_id']}, Participant #{row['participant_type']}##{row['participant_id']}: #{row['count']} duplicates"
      end
      issues << 'duplicate_participations'
    else
      puts '✓ No duplicate active participations found'
    end

    if issues.empty?
      puts "\n✅ All checks passed!"
    else
      puts "\n❌ Found issues: #{issues.join(', ')}"
      exit 1
    end
  end

  desc 'Backfill participations for existing conversations'
  task backfill_participations: :environment do
    puts 'Backfilling participations...'

    conversations = Conversation.all
    total = conversations.count
    processed = 0

    conversations.find_each do |conversation|
      ChatV2::BackfillParticipationsJob.perform_now(conversation.id)
      processed += 1
      print "\rProgress: #{processed}/#{total}" if (processed % 10).zero?
    end

    puts "\n✅ Backfill completed!"
  end

  desc 'Rehydrate missing V2 messages from legacy (by date range)'
  task :rehydrate_missing_v2_messages, %i[start_date end_date] => :environment do |_t, args|
    start_date = args[:start_date] ? Date.parse(args[:start_date]) : 7.days.ago
    end_date = args[:end_date] ? Date.parse(args[:end_date]) : Date.current

    puts "Rehydrating messages from #{start_date} to #{end_date}..."

    messages = BeneficiaryChatMessage.where(created_at: start_date..end_date).order(:beneficiary_id, :chat_group,
                                                                                    :created_at)
    total = messages.count
    processed = 0

    messages.find_each do |legacy_message|
      ChatV2::RehydrateMessageJob.perform_now(legacy_message.id)
      processed += 1
      print "\rProgress: #{processed}/#{total}" if (processed % 100).zero?
    end

    puts "\n✅ Rehydration completed!"
  end

  desc 'Backfill conversations from legacy'
  task backfill_conversations: :environment do
    puts 'Backfilling conversations from legacy...'

    conversations_created = 0
    BeneficiaryChatMessage
      .select('DISTINCT ON (beneficiary_id, chat_group) beneficiary_id, chat_group')
      .includes(:beneficiary)
      .find_each do |group|
        beneficiary = group.beneficiary
        next unless beneficiary

        chat_group = group.chat_group

        conversation = ChatV2::UpsertConversation.call(
          service: 'beneficiaries',
          context_type: 'Beneficiary',
          context_id: beneficiary.id,
          scope: chat_group,
          conversation_type: :group
        )

        conversations_created += 1
        ChatV2::BackfillParticipationsJob.perform_now(conversation.id)
      end

    puts "✅ Backfill completed! Conversations created: #{conversations_created}"
  end

  desc 'Verify legacy vs V2 message counts'
  task verify_counts: :environment do
    puts 'Verifying message counts...'

    mismatches = []
    total_conversations = 0

    Conversation.where(service: 'beneficiaries').find_each do |conversation|
      total_conversations += 1
      v2_count = ChatMessage.where(conversation_id: conversation.id).count

      if conversation.context_type == 'Beneficiary' && conversation.context_id.present?
        legacy_count = BeneficiaryChatMessage.where(
          beneficiary_id: conversation.context_id,
          chat_group: conversation.scope
        ).count

        status = v2_count == legacy_count ? 'OK' : 'MISMATCH'

        if status == 'MISMATCH'
          mismatches << {
            identifier: conversation.identifier,
            v2: v2_count,
            legacy: legacy_count,
            diff: v2_count - legacy_count
          }
        end

        puts "#{conversation.identifier} v2=#{v2_count} legacy=#{legacy_count} #{status}"
      end
    end

    if mismatches.any?
      puts "\n⚠️  Found #{mismatches.count} mismatches:"
      mismatches.each do |m|
        puts "  #{m[:identifier]}: v2=#{m[:v2]} legacy=#{m[:legacy]} (diff: #{m[:diff]})"
      end
      exit 1
    else
      puts "\n✅ All #{total_conversations} conversations match!"
    end
  end
end
