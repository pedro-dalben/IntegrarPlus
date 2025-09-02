# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CepController, type: :controller do
  include Devise::Test::ControllerHelpers

  describe 'GET #buscar' do
    context 'com CEP válido' do
      let(:cep) { '89010025' }
      let(:endereco_data) do
        {
          cep: '89010025',
          logradouro: 'Rua Doutor Luiz de Freitas Melro',
          bairro: 'Centro',
          cidade: 'Blumenau',
          uf: 'SC',
          coordenadas: {
            latitude: '-26.9244749',
            longitude: '-49.0629788'
          }
        }
      end

      before do
        allow(CepService).to receive(:buscar).with(cep).and_return(endereco_data)
      end

      it 'retorna os dados do endereço' do
        get :buscar, params: { cep: cep }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq(endereco_data.deep_stringify_keys)
      end
    end

    context 'com CEP inválido' do
      let(:cep) { 'invalid' }

      before do
        allow(CepService).to receive(:buscar).with(cep).and_return({ error: 'CEP inválido' })
      end

      it 'retorna erro' do
        get :buscar, params: { cep: cep }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to eq({ 'error' => 'CEP inválido' })
      end
    end

    context 'sem CEP' do
      it 'retorna bad request' do
        get :buscar, params: { cep: '' }

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to eq({ 'error' => 'CEP é obrigatório' })
      end
    end
  end
end
