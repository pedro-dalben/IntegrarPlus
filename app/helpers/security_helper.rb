# frozen_string_literal: true

module SecurityHelper
  # Sanitizar texto contra XSS e SQL Injection
  def sanitize_text(text)
    return '' if text.blank?

    # Remover caracteres de controle perigosos
    sanitized = text.gsub(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/, '')

    # Escape caracteres HTML/XML perigosos
    sanitized = sanitized.gsub(/[<>]/, '')

    # Remover scripts maliciosos
    sanitized = sanitized.gsub(%r{<script\b[^<]*(?:(?!</script>)<[^<]*)*</script>}mi, '')

    # Remover comandos SQL perigosos básicos
    sql_keywords = %w[SELECT INSERT UPDATE DELETE DROP CREATE ALTER EXEC EXECUTE UNION]
    sql_keywords.each do |keyword|
      sanitized = sanitized.gsub(/#{Regexp.escape(keyword)}/i, '')
    end

    sanitized
  end

  # Sanitizar CPF - manter apenas números e formatação
  def sanitize_cpf(cpf)
    return '' if cpf.blank?

    cpf.gsub(/[^0-9.-]/, '')
  end

  # Sanitizar telefone - manter apenas números e formatação
  def sanitize_phone(phone)
    return '' if phone.blank?

    phone.gsub(/[^0-9()\s-]/, '')
  end

  # Sanitizar CRM - manter apenas números
  def sanitize_crm(crm)
    return '' if crm.blank?

    crm.gsub(/[^0-9]/, '')
  end

  # Sanitizar CID - manter apenas letras, números e ponto
  def sanitize_cid(cid)
    return '' if cid.blank?

    cid.gsub(/[^A-Za-z0-9.]/, '').upcase
  end

  # Validar CPF usando algoritmo matemático
  def valid_cpf?(cpf)
    return false if cpf.blank?

    # Limpar CPF
    clean_cpf = cpf.gsub(/[^0-9]/, '')

    # Verificar se tem 11 dígitos
    return false unless clean_cpf.length == 11

    # Verificar se não são todos os dígitos iguais
    return false if clean_cpf.match?(/^(\d)\1{10}$/)

    # Primeiro dígito verificador
    sum = 0
    (0..8).each do |i|
      sum += clean_cpf[i].to_i * (10 - i)
    end
    first_digit = (sum * 10) % 11
    first_digit = 0 if first_digit == 10

    return false unless clean_cpf[9].to_i == first_digit

    # Segundo dígito verificador
    sum = 0
    (0..9).each do |i|
      sum += clean_cpf[i].to_i * (11 - i)
    end
    second_digit = (sum * 10) % 11
    second_digit = 0 if second_digit == 10

    clean_cpf[10].to_i == second_digit
  end

  # Validar data de nascimento
  def valid_birth_date?(date)
    return false if date.blank?

    begin
      birth_date = Date.parse(date.to_s)

      # Data não pode ser futura
      return false if birth_date > Date.current

      # Data não pode ser muito antiga (mais de 150 anos)
      return false if birth_date < 150.years.ago.to_date

      # Data não pode ser anterior a 1900
      return false if birth_date.year < 1900

      true
    rescue ArgumentError, TypeError
      false
    end
  end

  # Validar formato de telefone
  def valid_phone_format?(phone)
    return false if phone.blank?

    # Limpar telefone
    clean_phone = phone.gsub(/[^0-9]/, '')

    # Verificar se tem 10 ou 11 dígitos
    return false unless clean_phone.length.between?(10, 11)

    # Verificar se não são todos os dígitos iguais
    return false if clean_phone.match?(/^(\d)\1{9,10}$/)

    # Verificar se não contém números negativos
    return false if phone.match?(/-/)

    true
  end

  # Validar formato de CID
  def valid_cid_format?(cid)
    return false if cid.blank?

    # Limpar CID
    clean_cid = cid.upcase.strip

    # Verificar formato básico (letra + números + ponto + números)
    clean_cid.match?(/\A[A-Z]\d{2}\.\d{1,2}\z/)
  end

  # Validar formato de CRM
  def valid_crm_format?(crm)
    return false if crm.blank?

    # Limpar CRM
    clean_crm = crm.gsub(/[^0-9]/, '')

    # Verificar se tem 4 a 6 dígitos
    return false unless clean_crm.length.between?(4, 6)

    # Verificar se não são todos os dígitos iguais
    return false if clean_crm.match?(/^(\d)\1{3,5}$/)

    # Verificar se não começa com zero (exceto se for 4 dígitos)
    return false if clean_crm.length > 4 && clean_crm.start_with?('0')

    true
  end

  # Formatar CPF para exibição
  def format_cpf(cpf)
    return '' if cpf.blank?

    clean_cpf = cpf.gsub(/[^0-9]/, '')
    return cpf unless clean_cpf.length == 11

    "#{clean_cpf[0..2]}.#{clean_cpf[3..5]}.#{clean_cpf[6..8]}-#{clean_cpf[9..10]}"
  end

  # Formatar telefone para exibição
  def format_phone(phone)
    return '' if phone.blank?

    clean_phone = phone.gsub(/[^0-9]/, '')

    case clean_phone.length
    when 10
      clean_phone.gsub(/(\d{2})(\d{4})(\d{4})/, '(\1) \2-\3')
    when 11
      clean_phone.gsub(/(\d{2})(\d{5})(\d{4})/, '(\1) \2-\3')
    else
      phone
    end
  end
end
