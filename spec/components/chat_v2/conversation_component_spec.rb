# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatV2::ConversationComponent, type: :component do
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
    context 'when source is :legacy' do
      it 'renders conversation component' do
        component = described_class.new(
          conversation: conversation,
          current_user: user,
          source: :legacy
        )
        rendered = render_inline(component)
        expect(rendered).to have_css('.flex.h-full.flex-col')
      end
    end

    context 'when source is :v2' do
      it 'renders conversation component' do
        component = described_class.new(
          conversation: conversation,
          current_user: user,
          source: :v2
        )
        rendered = render_inline(component)
        expect(rendered).to have_css('.flex.h-full.flex-col')
      end
    end

    context 'when source is :auto' do
      it 'renders conversation component' do
        component = described_class.new(
          conversation: conversation,
          current_user: user,
          source: :auto
        )
        rendered = render_inline(component)
        expect(rendered).to have_css('.flex.h-full.flex-col')
      end
    end
  end
end
