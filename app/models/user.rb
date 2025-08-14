# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def permit?(_permission_key)
    # Por enquanto, retorna true para todas as permissões
    # TODO: Implementar sistema de permissões real
    true
  end
end
