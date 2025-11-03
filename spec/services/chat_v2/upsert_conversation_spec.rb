# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatV2::UpsertConversation do
  describe '.call' do
    context 'when conversation does not exist' do
      it 'creates a new conversation' do
        expect do
          described_class.call(
            service: 'beneficiaries',
            context_type: 'Beneficiary',
            context_id: 42,
            scope: 'general'
          )
        end.to change(Conversation, :count).by(1)
      end

      it 'generates correct identifier' do
        conversation = described_class.call(
          service: 'beneficiaries',
          context_type: 'Beneficiary',
          context_id: 42,
          scope: 'general'
        )

        expect(conversation.identifier).to eq('beneficiaries:beneficiary:42:general')
      end

      it 'sets default values' do
        conversation = described_class.call(
          service: 'beneficiaries',
          context_type: 'Beneficiary',
          context_id: 42
        )

        expect(conversation.service).to eq('beneficiaries')
        expect(conversation.context_type).to eq('Beneficiary')
        expect(conversation.context_id).to eq(42)
        expect(conversation.conversation_type).to eq('group')
        expect(conversation.status).to eq('active')
        expect(conversation.next_message_number).to eq(1)
        expect(conversation.messages_count).to eq(0)
      end
    end

    context 'when conversation exists' do
      let!(:existing_conversation) do
        described_class.call(
          service: 'beneficiaries',
          context_type: 'Beneficiary',
          context_id: 42,
          scope: 'general'
        )
      end

      it 'does not create a new conversation' do
        expect do
          described_class.call(
            service: 'beneficiaries',
            context_type: 'Beneficiary',
            context_id: 42,
            scope: 'general'
          )
        end.not_to change(Conversation, :count)
      end

      it 'returns existing conversation' do
        conversation = described_class.call(
          service: 'beneficiaries',
          context_type: 'Beneficiary',
          context_id: 42,
          scope: 'general'
        )

        expect(conversation.id).to eq(existing_conversation.id)
      end

      it 'updates metadata if provided' do
        conversation = described_class.call(
          service: 'beneficiaries',
          context_type: 'Beneficiary',
          context_id: 42,
          scope: 'general',
          metadata: { 'key' => 'value' }
        )

        expect(conversation.metadata).to eq({ 'key' => 'value' })
      end
    end
  end
end
