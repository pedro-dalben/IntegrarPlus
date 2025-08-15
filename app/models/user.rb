# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar

  def permit?(_permission_key)
    # Por enquanto, retorna true para todas as permissões
    # TODO: Implementar sistema de permissões real
    true
  end

  def full_name
    # Por enquanto, retorna o email como nome
    # TODO: Adicionar campos first_name e last_name ao modelo
    email.split('@').first.titleize
  end
end
