# frozen_string_literal: true

class CepDemoController < ApplicationController
  def index
    # Página de demonstração do componente de CEP
  end

  def address_demo
    # Página de demonstração do sistema de endereços
  end

  def create
    # Processar dados do formulário de exemplo
    @dados = params.permit(:nome, :email, :cep, :logradouro, :bairro, :cidade, :uf)

    if @dados[:cep].present?
      flash[:success] = "Dados recebidos com sucesso! CEP: #{@dados[:cep]}"
    else
      flash[:error] = 'CEP é obrigatório'
    end

    redirect_to cep_demo_index_path
  end
end
