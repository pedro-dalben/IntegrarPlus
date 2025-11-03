# frozen_string_literal: true

module AppFlags
  module_function

  def chat_v2_enabled?
    return false if enforce_legacy_only?

    ENV.fetch('CHAT_V2_ENABLED', 'false') == 'true'
  end

  def enforce_legacy_only?
    ENV.fetch('CHAT_V2_ENFORCE_LEGACY_ONLY', 'false') == 'true'
  end

  def chat_v2_enabled_for?(_tenant = nil)
    chat_v2_enabled?
  end
end
