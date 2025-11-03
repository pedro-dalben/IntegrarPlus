# frozen_string_literal: true

module ChatV2
  class UpsertConversation
    def self.call(service:, context_type:, context_id:, scope: nil, conversation_type: :group, metadata: {})
      new(service: service, context_type: context_type, context_id: context_id, scope: scope,
          conversation_type: conversation_type, metadata: metadata).call
    end

    def initialize(service:, context_type:, context_id:, scope: nil, conversation_type: :group, metadata: {})
      @service = service
      @context_type = context_type
      @context_id = context_id
      @scope = scope
      @conversation_type = conversation_type
      @metadata = metadata
    end

    def call
      identifier = Conversation.generate_identifier(
        service: @service,
        context_type: @context_type,
        context_id: @context_id,
        scope: @scope
      )

      Conversation.transaction do
        conversation = Conversation.find_or_initialize_by(identifier: identifier)

        if conversation.new_record?
          conversation.assign_attributes(
            service: @service,
            context_type: @context_type.to_s,
            context_id: @context_id,
            scope: @scope,
            conversation_type: @conversation_type,
            metadata: @metadata,
            status: :active
          )
          conversation.save!
        elsif @metadata.present?
          conversation.update!(metadata: @metadata)
        end

        conversation
      end
    end
  end
end
