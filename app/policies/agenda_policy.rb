# frozen_string_literal: true

class AgendaPolicy < ApplicationPolicy
  def index?
    user.admin? || user.secretary?
  end

  def show?
    user.admin? || user.secretary?
  end

  def new?
    user.admin? || user.secretary?
  end

  def create?
    user.admin? || user.secretary?
  end

  def edit?
    user.admin? || user.secretary?
  end

  def update?
    user.admin? || user.secretary?
  end

  def destroy?
    user.admin? && record.can_be_deleted?
  end

  def archive?
    user.admin? || user.secretary?
  end

  def activate?
    user.admin? || user.secretary?
  end

  def duplicate?
    user.admin? || user.secretary?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.secretary?
        scope.all
      else
        scope.none
      end
    end
  end
end
