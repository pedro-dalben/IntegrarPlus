# frozen_string_literal: true

class CepService
  include HTTParty
  base_uri 'https://brasilapi.com.br/api/cep/v2'

  def self.search(zip_code)
    return { error: 'Invalid ZIP code' } unless valid_zip_code?(zip_code)

    clean_zip = clean_zip_code(zip_code)

    begin
      response = get("/#{clean_zip}")

      if response.success?
        format_response(response.parsed_response)
      else
        { error: 'ZIP code not found' }
      end
    rescue StandardError => e
      Rails.logger.error "Error searching ZIP code #{zip_code}: #{e.message}"
      { error: 'Error consulting ZIP code' }
    end
  end

  # Keep legacy method for backward compatibility
  def self.buscar(cep)
    search(cep)
  end

  private

  def self.valid_zip_code?(zip_code)
    return false if zip_code.blank?

    clean_zip = clean_zip_code(zip_code)
    clean_zip.match?(/\A\d{8}\z/)
  end

  def self.clean_zip_code(zip_code)
    zip_code.to_s.gsub(/\D/, '')
  end

  def self.format_response(data)
    {
      zip_code: data['cep'],
      street: data['street'],
      neighborhood: data['neighborhood'],
      city: data['city'],
      state: data['state'],
      coordinates: {
        latitude: data.dig('location', 'coordinates', 'latitude'),
        longitude: data.dig('location', 'coordinates', 'longitude')
      }
    }
  end

  # Legacy method names for backward compatibility
  def self.cep_valido?(cep)
    valid_zip_code?(cep)
  end

  def self.limpar_cep(cep)
    clean_zip_code(cep)
  end

  def self.formatar_resposta(data)
    format_response(data)
  end
end
