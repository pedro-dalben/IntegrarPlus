# frozen_string_literal: true

class ProfessionalPolicy < ApplicationPolicy
  def access?
    user.present? && user.professional.present?
  end

  def index?
    access?
  end

  def show?
    access?
  end

  def availability?
    access?
  end
end
