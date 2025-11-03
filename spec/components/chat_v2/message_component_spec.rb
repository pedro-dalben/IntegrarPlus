# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatV2::MessageComponent, type: :component do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
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
    context 'when message is from current user' do
      it 'renders message aligned to right' do
        message = ChatV2::SendMessage.call(
          conversation: conversation,
          sender: user,
          body: 'My message'
        )

        component = described_class.new(message: message, current_user: user)
        rendered = render_inline(component)
        expect(rendered).to have_css('.justify-end')
        expect(rendered).to have_css('.bg-brand-500')
      end
    end

    context 'when message is from other user' do
      it 'renders message aligned to left' do
        message = ChatV2::SendMessage.call(
          conversation: conversation,
          sender: other_user,
          body: 'Other message'
        )

        component = described_class.new(message: message, current_user: user)
        rendered = render_inline(component)
        expect(rendered).to have_css('.justify-start')
        expect(rendered).to have_css('.bg-gray-100')
      end
    end
  end
end
