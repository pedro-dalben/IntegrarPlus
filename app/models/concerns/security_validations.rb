# frozen_string_literal: true

module SecurityValidations
  extend ActiveSupport::Concern

  included do
    # Validações de segurança
    validate :sanitize_text_fields
    validate :validate_cpf_format_and_algorithm, if: :cpf_present?
    validate :validate_birth_date_range, if: :data_nascimento_present?
    validate :validate_phone_format, if: :telefone_responsavel_present?
    validate :validate_cid_format, if: :cid_present?
    validate :validate_crm_format, if: :medico_crm_present?

    # Sanitização automática antes da validação
    before_validation :sanitize_all_text_fields
    before_validation :trim_whitespace
  end

  private

  # Sanitização contra SQL Injection e XSS
  def sanitize_all_text_fields
    text_fields.each do |field|
      value = send(field)
      next if value.blank?

      # Remove caracteres de controle perigosos
      sanitized_value = value.gsub(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/, '')

      # Escape caracteres HTML/XML perigosos
      sanitized_value = sanitized_value.gsub(/[<>]/, '')

      # Remove scripts maliciosos
      sanitized_value = sanitized_value.gsub(%r{<script\b[^<]*(?:(?!</script>)<[^<]*)*</script>}mi, '')

      # Remove comandos SQL perigosos
      sql_keywords = %w[SELECT INSERT UPDATE DELETE DROP CREATE ALTER EXEC EXECUTE UNION]
      sql_keywords.each do |keyword|
        sanitized_value = sanitized_value.gsub(/#{Regexp.escape(keyword)}/i, '')
      end

      send("#{field}=", sanitized_value)
    end
  end

  def trim_whitespace
    text_fields.each do |field|
      value = send(field)
      next if value.blank?

      send("#{field}=", value.strip)
    end
  end

  def sanitize_text_fields
    text_fields.each do |field|
      value = send(field)
      next if value.blank?

      # Verificar se ainda contém caracteres perigosos após sanitização
      errors.add(field, 'contém caracteres não permitidos') if value.match?(/[<>]/)

      errors.add(field, 'contém código JavaScript não permitido') if value.match?(/<script\b/i)

      # Verificar comandos SQL básicos
      sql_patterns = [
        /\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER)\b/i,
        /(\bUNION\b.*\bSELECT\b)/i,
        /(\bEXEC\b|\bEXECUTE\b)/i
      ]

      sql_patterns.each do |pattern|
        if value.match?(pattern)
          errors.add(field, 'contém comandos SQL não permitidos')
          break
        end
      end
    end
  end

  # Validação matemática de CPF
  def validate_cpf_format_and_algorithm
    return if cpf.blank?

    # Limpar CPF (remover pontos, traços, espaços)
    clean_cpf = cpf.gsub(/[^0-9]/, '')

    # Verificar se tem 11 dígitos
    unless clean_cpf.length == 11
      errors.add(:cpf, 'deve ter exatamente 11 dígitos')
      return
    end

    # Verificar se não são todos os dígitos iguais
    if clean_cpf.match?(/^(\d)\1{10}$/)
      errors.add(:cpf, 'não pode ter todos os dígitos iguais')
      return
    end

    # Validar algoritmo do CPF
    return if valid_cpf_algorithm?(clean_cpf)

    errors.add(:cpf, 'não é um CPF válido')
  end

  def valid_cpf_algorithm?(cpf)
    return false if cpf.length != 11

    # Primeiro dígito verificador
    sum = 0
    (0..8).each do |i|
      sum += cpf[i].to_i * (10 - i)
    end
    first_digit = (sum * 10) % 11
    first_digit = 0 if first_digit == 10

    return false if cpf[9].to_i != first_digit

    # Segundo dígito verificador
    sum = 0
    (0..9).each do |i|
      sum += cpf[i].to_i * (11 - i)
    end
    second_digit = (sum * 10) % 11
    second_digit = 0 if second_digit == 10

    cpf[10].to_i == second_digit
  end

  # Validação de data de nascimento
  def validate_birth_date_range
    return if data_nascimento.blank?

    begin
      birth_date = Date.parse(data_nascimento.to_s)

      # Data não pode ser futura
      errors.add(:data_nascimento, 'não pode ser uma data futura') if birth_date > Date.current

      # Data não pode ser muito antiga (mais de 150 anos)
      errors.add(:data_nascimento, 'não pode ser anterior a 150 anos') if birth_date < 150.years.ago.to_date

      # Data não pode ser negativa ou inválida
      errors.add(:data_nascimento, 'ano deve ser maior que 1900') if birth_date.year < 1900
    rescue ArgumentError, TypeError
      errors.add(:data_nascimento, 'formato de data inválido')
    end
  end

  # Validação de formato de telefone
  def validate_phone_format
    return if telefone_responsavel.blank?

    # Limpar telefone
    clean_phone = telefone_responsavel.gsub(/[^0-9]/, '')

    # Verificar se tem 10 ou 11 dígitos
    unless clean_phone.length.between?(10, 11)
      errors.add(:telefone_responsavel, 'deve ter 10 ou 11 dígitos')
      return
    end

    # Verificar se não são todos os dígitos iguais
    errors.add(:telefone_responsavel, 'não pode ter todos os dígitos iguais') if clean_phone.match?(/^(\d)\1{9,10}$/)
  end

  # Métodos auxiliares
  def text_fields
    # Campos de texto que precisam ser sanitizados
    if self.class.name == 'PortalIntake'
      %w[nome responsavel endereco convenio plan_name card_code carteira_codigo]
    elsif self.class.name == 'PortalIntakeReferral'
      %w[medico descricao]
    else
      []
    end
  end

  def cpf_present?
    cpf.present?
  end

  def data_nascimento_present?
    data_nascimento.present?
  end

  def telefone_responsavel_present?
    telefone_responsavel.present?
  end

  # Validações específicas para PortalIntakeReferral
  def validate_cid_format
    return if cid.blank?

    # Limpar CID
    clean_cid = cid.upcase.strip

    # Verificar formato básico (letra + números + ponto + números)
    unless clean_cid.match?(/\A[A-Z]\d{2}\.\d{1,2}\z/)
      errors.add(:cid, 'deve estar no formato A00.0 (ex: F84.0)')
      return
    end

    # Verificar se a letra inicial é válida (A-Z)
    errors.add(:cid, 'deve começar com uma letra maiúscula') unless clean_cid[0].match?(/[A-Z]/)

    # Verificar se os números seguem o padrão correto
    parts = clean_cid.split('.')
    if parts.length != 2
      errors.add(:cid, 'formato inválido')
      return
    end

    # Primeira parte deve ter 3 caracteres (letra + 2 dígitos)
    unless parts[0].length == 3 && parts[0][1..2].match?(/\d{2}/)
      errors.add(:cid, 'primeira parte deve ter formato A00')
    end

    # Segunda parte deve ter 1 ou 2 dígitos
    return if parts[1].match?(/\d{1,2}/)

    errors.add(:cid, 'segunda parte deve ter 1 ou 2 dígitos')
  end

  def validate_crm_format
    return if medico_crm.blank?

    # Limpar CRM
    clean_crm = medico_crm.gsub(/[^0-9]/, '')

    # Verificar se tem 4 a 6 dígitos
    unless clean_crm.length.between?(4, 6)
      errors.add(:medico_crm, 'deve ter entre 4 e 6 dígitos')
      return
    end

    # Verificar se não são todos os dígitos iguais
    errors.add(:medico_crm, 'não pode ter todos os dígitos iguais') if clean_crm.match?(/^(\d)\1{3,5}$/)

    # Verificar se não começa com zero (exceto se for 4 dígitos e começar com 0)
    return unless clean_crm.length > 4 && clean_crm.start_with?('0')

    errors.add(:medico_crm, 'não pode começar com zero')
  end

  def cid_present?
    respond_to?(:cid) && cid.present?
  end

  def medico_crm_present?
    respond_to?(:medico_crm) && medico_crm.present?
  end
end
