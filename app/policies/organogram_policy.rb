# frozen_string_literal: true

class OrganogramPolicy < ApplicationPolicy
  def index?
    user.is_a?(User) && user.permit?('organograms.index')
  end

  def show?
    user.is_a?(User) && (
      user.permit?('organograms.show') ||
      user.permit?('organograms.view') ||
      record.created_by == user
    )
  end

  def create?
    user.is_a?(User) && (
      user.permit?('organograms.create') ||
      user.admin?
    )
  end

  def new?
    create?
  end

  def update?
    user.is_a?(User) && (
      user.permit?('organograms.update') ||
      user.admin? ||
      record.created_by == user
    )
  end

  def edit?
    update?
  end

  def destroy?
    user.is_a?(User) && (
      user.permit?('organograms.destroy') ||
      user.admin? ||
      record.created_by == user
    )
  end

  def editor?
    update?
  end

  def export_json?
    user.is_a?(User) && (
      user.permit?('organograms.export') ||
      show?
    )
  end

  def export_pdf?
    export_json?
  end

  def import_json?
    user.is_a?(User) && (
      user.permit?('organograms.import') ||
      update?
    )
  end

  def import_csv?
    import_json?
  end

  def publish?
    user.is_a?(User) && (
      user.permit?('organograms.publish') ||
      user.admin?
    )
  end

  def unpublish?
    publish?
  end

  class Scope < Scope
    def resolve
      if user.is_a?(User)
        if user.admin? || user.permit?('organograms.index')
          scope.all
        elsif user.permit?('organograms.show') || user.permit?('organograms.view')
          scope.published
        else
          scope.where(created_by: user)
        end
      else
        scope.none
      end
    end
  end
end
