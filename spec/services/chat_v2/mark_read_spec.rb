# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatV2::MarkRead do
  let(:user) { create(:user) }
  let(:conversation) do
    ChatV2::UpsertConversation.call(
      service: 'beneficiaries',
      context_type: 'Beneficiary',
      context_id: 1,
      scope: 'general'
    )
  end

  describe '.call' do
    context 'when participation does not exist' do
      it 'creates a new participation' do
        expect do
          described_class.call(
            conversation: conversation,
            participant: user,
            message_number: 5
          )
        end.to change(ConversationParticipation, :count).by(1)
      end

      it 'sets default role and preferences' do
        participation = described_class.call(
          conversation: conversation,
          participant: user,
          message_number: 5
        )

        expect(participation.role).to eq('member')
        expect(participation.notifications_enabled).to be true
        expect(participation.joined_at).to be_present
      end

      it 'sets last_read_message_number' do
        participation = described_class.call(
          conversation: conversation,
          participant: user,
          message_number: 5
        )

        expect(participation.last_read_message_number).to eq(5)
      end
    end

    context 'when participation exists' do
      let!(:participation) do
        ChatV2::MarkRead.call(
          conversation: conversation,
          participant: user,
          message_number: 3
        )
      end

      it 'does not create a new participation' do
        expect do
          described_class.call(
            conversation: conversation,
            participant: user,
            message_number: 5
          )
        end.not_to change(ConversationParticipation, :count)
      end

      it 'updates last_read_message_number to max value' do
        described_class.call(
          conversation: conversation,
          participant: user,
          message_number: 5
        )

        participation.reload
        expect(participation.last_read_message_number).to eq(5)
      end

      it 'does not decrease last_read_message_number' do
        described_class.call(
          conversation: conversation,
          participant: user,
          message_number: 2
        )

        participation.reload
        expect(participation.last_read_message_number).to eq(3)
      end

      it 'updates unread_count' do
        conversation.update!(messages_count: 10)

        described_class.call(
          conversation: conversation,
          participant: user,
          message_number: 7
        )

        participation.reload
        expect(participation.unread_count).to eq(3)
      end
    end

    context 'when message_number is not provided' do
      it 'uses messages_count as default' do
        conversation.update!(messages_count: 8)

        participation = described_class.call(
          conversation: conversation,
          participant: user
        )

        expect(participation.last_read_message_number).to eq(8)
        expect(participation.unread_count).to eq(0)
      end
    end
  end
end
