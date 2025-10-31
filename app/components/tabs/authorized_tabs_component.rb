# frozen_string_literal: true

module Tabs
  class AuthorizedTabsComponent < ViewComponent::Base
    def initialize(user:, resource:, tabs: [], initial_key: nil)
      @user = user
      @resource = resource
      @tabs = tabs
      @initial_key = initial_key || tab_from_params
    end

    def visible_tabs
      @tabs.select do |tab|
        TabAccessService.user_can_access_tab?(@user, @resource, tab[:key], :show)
      end
    end

    def initial_active_key
      keys = visible_tabs.pluck(:key)
      return keys.first if @initial_key.blank? || keys.exclude?(@initial_key)

      @initial_key
    end

    private

    def tab_from_params
      return nil unless helpers.respond_to?(:params)

      tab_param = helpers.params[:tab] || helpers.params['tab']
      tab_param.presence
    end
  end
end
