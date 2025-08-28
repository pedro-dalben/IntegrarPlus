# frozen_string_literal: true

class CepController < ApplicationController
  def search
    zip_code = params[:zip_code] || params[:cep]

    if zip_code.blank?
      render json: { error: 'ZIP code is required' }, status: :bad_request
      return
    end

    result = CepService.search(zip_code)

    if result[:error]
      render json: result, status: :unprocessable_entity
    else
      render json: result
    end
  end

  # Keep legacy method for backward compatibility
  alias_method :buscar, :search
end
