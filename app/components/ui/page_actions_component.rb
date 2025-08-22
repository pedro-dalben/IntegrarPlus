# frozen_string_literal: true

module Ui
  class PageActionsComponent < ViewComponent::Base
    renders_one :back_button
    renders_one :edit_button

    def initialize(back_path:, edit_path: nil)
      @back_path = back_path
      @edit_path = edit_path
    end

    private

    attr_reader :back_path, :edit_path
  end
end
