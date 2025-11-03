# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatMessage, type: :model do
  let(:conversation) { create(:conversation) }
  let(:user) { create(:user) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:conversation_id) }
    it { is_expected.to validate_presence_of(:message_number) }
    it { is_expected.to validate_presence_of(:sender_type) }
    it { is_expected.to validate_presence_of(:sender_id) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_length_of(:body).is_at_most(10_000) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:content_type).with_values(text: 0, image: 1, file: 2, system: 3, sticker: 4) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:conversation) }
    it { is_expected.to belong_to(:sender) }
  end

  describe 'uniqueness' do
    it 'validates message_number is unique per conversation' do
      create(:chat_message, conversation: conversation, message_number: 1, sender: user)
      message = build(:chat_message, conversation: conversation, message_number: 1, sender: user)
      expect(message).not_to be_valid
      expect(message.errors[:message_number]).to be_present
    end

    it 'allows same message_number in different conversations' do
      conversation2 = create(:conversation)
      create(:chat_message, conversation: conversation, message_number: 1, sender: user)
      message = build(:chat_message, conversation: conversation2, message_number: 1, sender: user)
      expect(message).to be_valid
    end
  end
end
