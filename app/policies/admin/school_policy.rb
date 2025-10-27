module Admin
  class SchoolPolicy < ApplicationPolicy
    def index?
      user.permit?('schools.view')
    end

    def show?
      user.permit?('schools.view')
    end

    def create?
      user.permit?('schools.create')
    end

    def update?
      user.permit?('schools.edit')
    end

    def destroy?
      user.permit?('schools.destroy')
    end

    def activate?
      user.permit?('schools.edit')
    end

    def deactivate?
      user.permit?('schools.edit')
    end

    def search?
      user.permit?('schools.view')
    end
  end
end
