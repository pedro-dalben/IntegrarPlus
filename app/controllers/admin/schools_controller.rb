# frozen_string_literal: true

module Admin
  class SchoolsController < Admin::BaseController
    def search
      query = params[:q]

      if query.blank? || query.length < 3
        render json: { schools: [], message: 'Digite pelo menos 3 caracteres para buscar' }
        return
      end

      begin
        schools = search_schools_in_inep(query)
        render json: { schools: schools }
      rescue StandardError => e
        Rails.logger.error "Erro ao buscar escolas: #{e.message}"
        render json: { schools: [], error: 'Erro ao buscar escolas. Tente novamente.' }
      end
    end

    private

    def search_schools_in_inep(query)
      # Simulação de busca - em produção, integrar com API real do INEP
      # Por enquanto, retornamos dados mockados baseados em escolas reais

      mock_schools = [
        {
          id: 1,
          name: "Escola Municipal #{query} - Centro",
          code: '12345678',
          address: 'Rua das Flores, 123 - Centro',
          city: 'São Paulo',
          state: 'SP',
          type: 'Municipal'
        },
        {
          id: 2,
          name: "Escola Estadual #{query} - Vila Nova",
          code: '87654321',
          address: 'Av. Principal, 456 - Vila Nova',
          city: 'São Paulo',
          state: 'SP',
          type: 'Estadual'
        },
        {
          id: 3,
          name: "Colégio Particular #{query}",
          code: '11223344',
          address: 'Rua da Educação, 789 - Jardim',
          city: 'São Paulo',
          state: 'SP',
          type: 'Particular'
        }
      ]

      # Filtrar escolas que contenham o termo de busca
      mock_schools.select do |school|
        school[:name].downcase.include?(query.downcase) ||
          school[:address].downcase.include?(query.downcase) ||
          school[:city].downcase.include?(query.downcase)
      end.first(10) # Limitar a 10 resultados
    end

    # Método para integração futura com API real do INEP
    def search_real_inep_api(query)
      # Exemplo de como seria a integração real:
      # require 'net/http'
      # require 'json'
      #
      # uri = URI("https://api.inep.gov.br/escolas")
      # params = { q: query, limit: 10 }
      # uri.query = URI.encode_www_form(params)
      #
      # response = Net::HTTP.get_response(uri)
      # if response.is_a?(Net::HTTPSuccess)
      #   JSON.parse(response.body)
      # else
      #   []
      # end
    end
  end
end
