# frozen_string_literal: true

class WorkspacePolicy < ApplicationPolicy
  def index?
    user.admin? || user.permit?('documents.access') || user.professional&.can_access_documents?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
