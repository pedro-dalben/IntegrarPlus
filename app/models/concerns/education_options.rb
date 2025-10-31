# frozen_string_literal: true

module EducationOptions
  extend ActiveSupport::Concern

  EDUCATION_OPTIONS = [
    ['Selecione...', ''],
    ['Analfabeto', 'analfabeto'],
    ['Ensino Fundamental Incompleto', 'fundamental_incompleto'],
    ['Ensino Fundamental Completo', 'fundamental_completo'],
    ['Ensino Médio Incompleto', 'medio_incompleto'],
    ['Ensino Médio Completo', 'medio_completo'],
    ['Ensino Superior Incompleto', 'superior_incompleto'],
    ['Ensino Superior Completo', 'superior_completo'],
    ['Pós-graduação', 'pos_graduacao']
  ].freeze

  EDUCATION_LABELS = {
    'analfabeto' => 'Analfabeto',
    'fundamental_incompleto' => 'Ensino Fundamental Incompleto',
    'fundamental_completo' => 'Ensino Fundamental Completo',
    'medio_incompleto' => 'Ensino Médio Incompleto',
    'medio_completo' => 'Ensino Médio Completo',
    'superior_incompleto' => 'Ensino Superior Incompleto',
    'superior_completo' => 'Ensino Superior Completo',
    'pos_graduacao' => 'Pós-graduação'
  }.freeze

  included do
    def self.education_options
      EducationOptions::EDUCATION_OPTIONS
    end

    def education_label(education_value)
      return '' if education_value.blank?

      EducationOptions::EDUCATION_LABELS[education_value.to_s] || education_value.to_s.humanize
    end
  end
end
