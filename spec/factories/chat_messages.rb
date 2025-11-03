# frozen_string_literal: true

FactoryBot.define do
  factory :chat_message do
    association :conversation, factory: :conversation
    association :sender, factory: :user
    sequence(:message_number) { |n| n }
    content_type { :text }
    sequence(:body) { |n| "Message body #{n}" }
    metadata { {} }
  end
end
