# frozen_string_literal: true

class ReleasedDocumentsPolicy < ApplicationPolicy
  def index?
    user.admin? || user.permit?('documents.view_released') || user.professional&.can_view_released?
  end

  def show?
    user.admin? || user.permit?('documents.view_released') || user.professional&.can_view_released?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
