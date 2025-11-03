# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatV2::SendMessage do
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
    it 'creates a new message' do
      expect do
        described_class.call(
          conversation: conversation,
          sender: user,
          body: 'Hello world'
        )
      end.to change(ChatMessage, :count).by(1)
    end

    it 'assigns sequential message_number' do
      message1 = described_class.call(
        conversation: conversation,
        sender: user,
        body: 'First message'
      )

      message2 = described_class.call(
        conversation: conversation,
        sender: user,
        body: 'Second message'
      )

      expect(message1.message_number).to eq(1)
      expect(message2.message_number).to eq(2)
    end

    it 'increments next_message_number atomically' do
      described_class.call(
        conversation: conversation,
        sender: user,
        body: 'Hello'
      )

      conversation.reload
      expect(conversation.next_message_number).to eq(2)
    end

    it 'updates conversation counters' do
      message = described_class.call(
        conversation: conversation,
        sender: user,
        body: 'Hello'
      )

      conversation.reload
      expect(conversation.messages_count).to eq(1)
      expect(conversation.last_message_id).to eq(message.id)
      expect(conversation.last_message_at).to be_within(1.second).of(message.created_at)
    end

    it 'handles concurrent messages correctly' do
      threads = Array.new(5) do |i|
        Thread.new do
          described_class.call(
            conversation: conversation,
            sender: user,
            body: "Message #{i}"
          )
        end
      end

      threads.each(&:join)
      conversation.reload

      expect(conversation.messages_count).to eq(5)
      expect(ChatMessage.where(conversation: conversation).count).to eq(5)
      message_numbers = ChatMessage.where(conversation: conversation).pluck(:message_number).sort
      expect(message_numbers).to eq([1, 2, 3, 4, 5])
    end
  end
end
