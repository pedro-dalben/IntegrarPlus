# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Conversation, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:identifier) }
    it { is_expected.to validate_presence_of(:service) }
    it { is_expected.to validate_presence_of(:context_type) }
    it { is_expected.to validate_presence_of(:context_id) }
    it { is_expected.to validate_uniqueness_of(:identifier) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:conversation_type).with_values(group: 0, direct: 1, channel: 2, thread: 3) }
    it { is_expected.to define_enum_for(:status).with_values(active: 0, archived: 1, deleted: 2) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:chat_messages).dependent(:destroy) }
    it { is_expected.to have_many(:conversation_participations).dependent(:destroy) }
  end

  describe '.generate_identifier' do
    it 'generates correct identifier without scope' do
      identifier = Conversation.generate_identifier(
        service: 'beneficiaries',
        context_type: 'Beneficiary',
        context_id: 42
      )
      expect(identifier).to eq('beneficiaries:beneficiary:42')
    end

    it 'generates correct identifier with scope' do
      identifier = Conversation.generate_identifier(
        service: 'beneficiaries',
        context_type: 'Beneficiary',
        context_id: 42,
        scope: 'general'
      )
      expect(identifier).to eq('beneficiaries:beneficiary:42:general')
    end
  end

  describe '#ensure_identifier' do
    it 'generates identifier before validation' do
      conversation = Conversation.new(
        service: 'beneficiaries',
        context_type: 'Beneficiary',
        context_id: 42,
        scope: 'general'
      )
      conversation.valid?
      expect(conversation.identifier).to eq('beneficiaries:beneficiary:42:general')
    end
  end
end
