# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatV2::MessageListComponent, type: :component do
  let(:user) { create(:user) }
  let(:beneficiary) { create(:beneficiary) }
  let(:conversation) do
    ChatV2::UpsertConversation.call(
      service: 'beneficiaries',
      context_type: 'Beneficiary',
      context_id: beneficiary.id,
      scope: 'general',
      conversation_type: :group
    )
  end

  describe '#render_in' do
    it 'renders message list with V2 messages' do
      ChatV2::SendMessage.call(
        conversation: conversation,
        sender: user,
        body: 'Test message'
      )

      component = described_class.new(
        conversation: conversation,
        current_user: user
      )
      rendered = render_inline(component)
      expect(rendered).to have_css("[id='chat-#{conversation.identifier}-list']")
    end
  end

  describe 'Turbo Stream broadcast' do
    it 'broadcasts append when message is created' do
      allow(AppFlags).to receive(:chat_v2_enabled?).and_return(true)

      expect do
        ChatV2::SendMessage.call(
          conversation: conversation,
          sender: user,
          body: 'Test message'
        )
      end.to have_broadcasted_to("chat:#{conversation.identifier}").with(
        hash_including(partial: 'components/chat_v2/message')
      )
    end
  end
end
