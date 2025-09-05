class AgendaTemplatePolicy < ApplicationPolicy
  def index?
    user.admin? || user.can?(:view_agenda_templates)
  end

  def show?
    user.admin? || record.can_be_used_by?(user)
  end

  def create?
    user.admin? || user.can?(:create_agenda_templates)
  end

  def update?
    user.admin? || (record.created_by == user && user.can?(:edit_own_agenda_templates))
  end

  def destroy?
    user.admin? || (record.created_by == user && user.can?(:delete_own_agenda_templates))
  end

  def duplicate?
    show?
  end

  def create_from_agenda?
    user.admin? || user.can?(:create_agenda_templates)
  end

  def create_agenda_from_template?
    show?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.visible_for_user(user)
      end
    end
  end
end
