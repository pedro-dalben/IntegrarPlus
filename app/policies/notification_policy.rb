class NotificationPolicy < ApplicationPolicy
  def index?
    user.admin? || user.permit?('notifications.index')
  end

  def show?
    user.admin? || user.permit?('notifications.show') || record.user == user
  end

  def create?
    user.admin? || user.permit?('notifications.create')
  end

  def update?
    user.admin? || user.permit?('notifications.update') || record.user == user
  end

  def destroy?
    user.admin? || user.permit?('notifications.destroy')
  end

  def mark_as_read?
    user.admin? || user.permit?('notifications.update') || record.user == user
  end

  def mark_as_unread?
    user.admin? || user.permit?('notifications.update') || record.user == user
  end

  def mark_all_as_read?
    user.admin? || user.permit?('notifications.update')
  end

  def preferences?
    user.admin? || user.permit?('notifications.preferences')
  end

  def update_preferences?
    user.admin? || user.permit?('notifications.preferences')
  end

  def templates?
    user.admin? || user.permit?('notifications.templates')
  end

  def create_default_templates?
    user.admin? || user.permit?('notifications.templates')
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end
end


