module BrazilianDocumentValidation
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_cpf, if: -> { cpf.present? }
    before_validation :normalize_cnpj, if: -> { cnpj.present? }

    validate :cpf_must_be_valid, if: -> { cpf.present? }
    validate :cnpj_must_be_valid, if: -> { cnpj.present? && contract_type&.requires_cnpj? }
  end

  private

  def normalize_cpf
    self.cpf = cpf.to_s.gsub(/\D/, '')
  end

  def normalize_cnpj
    return if cnpj.blank?
    self.cnpj = cnpj.to_s.gsub(/\D/, '')
  end

  def cpf_must_be_valid
    return if valid_cpf?(cpf)
    errors.add(:cpf, 'não é válido')
  end

  def cnpj_must_be_valid
    return if valid_cnpj?(cnpj)
    errors.add(:cnpj, 'não é válido')
  end

  def valid_cpf?(cpf)
    cpf = cpf.to_s.gsub(/\D/, '')
    return false if cpf.length != 11
    return false if cpf.chars.uniq.length == 1

    digits = cpf.chars.map(&:to_i)

    sum = 0
    9.times { |i| sum += digits[i] * (10 - i) }
    remainder = sum % 11
    check1 = remainder < 2 ? 0 : 11 - remainder
    return false if check1 != digits[9]

    sum = 0
    10.times { |i| sum += digits[i] * (11 - i) }
    remainder = sum % 11
    check2 = remainder < 2 ? 0 : 11 - remainder

    check2 == digits[10]
  end

  def valid_cnpj?(cnpj)
    return true if cnpj.blank?

    cnpj = cnpj.to_s.gsub(/\D/, '')
    return false if cnpj.length != 14
    return false if cnpj.chars.uniq.length == 1

    digits = cnpj.chars.map(&:to_i)

    multipliers_first = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
    sum = 0
    12.times { |i| sum += digits[i] * multipliers_first[i] }
    remainder = sum % 11
    check1 = remainder < 2 ? 0 : 11 - remainder
    return false if check1 != digits[12]

    multipliers_second = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
    sum = 0
    13.times { |i| sum += digits[i] * multipliers_second[i] }
    remainder = sum % 11
    check2 = remainder < 2 ? 0 : 11 - remainder

    check2 == digits[13]
  end
end
