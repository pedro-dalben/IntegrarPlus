# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.describe CepService do
  describe '.buscar' do
    context 'com CEP válido' do
      let(:cep) { '89010025' }
      let(:response_body) do
        {
          'cep' => '89010025',
          'state' => 'SC',
          'city' => 'Blumenau',
          'neighborhood' => 'Centro',
          'street' => 'Rua Doutor Luiz de Freitas Melro',
          'service' => 'viacep',
          'location' => {
            'type' => 'Point',
            'coordinates' => {
              'longitude' => '-49.0629788',
              'latitude' => '-26.9244749'
            }
          }
        }
      end

      before do
        stub_request(:get, "https://brasilapi.com.br/api/cep/v2/#{cep}")
          .to_return(status: 200, body: response_body.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'retorna os dados formatados corretamente' do
        resultado = described_class.buscar(cep)

        expect(resultado).to eq({
          cep: '89010025',
          logradouro: 'Rua Doutor Luiz de Freitas Melro',
          bairro: 'Centro',
          cidade: 'Blumenau',
          uf: 'SC',
          coordenadas: {
            latitude: '-26.9244749',
            longitude: '-49.0629788'
          }
        })
      end

      it 'funciona com CEP formatado' do
        resultado = described_class.buscar('89010-025')
        expect(resultado[:cep]).to eq('89010025')
      end
    end

    context 'com CEP inválido' do
      it 'retorna erro para CEP vazio' do
        resultado = described_class.buscar('')
        expect(resultado).to eq({ error: 'CEP inválido' })
      end

      it 'retorna erro para CEP com formato inválido' do
        resultado = described_class.buscar('123')
        expect(resultado).to eq({ error: 'CEP inválido' })
      end

      it 'retorna erro para CEP com letras' do
        resultado = described_class.buscar('abcdefgh')
        expect(resultado).to eq({ error: 'CEP inválido' })
      end
    end

    context 'com CEP não encontrado' do
      let(:cep) { '00000000' }

      before do
        stub_request(:get, "https://brasilapi.com.br/api/cep/v2/#{cep}")
          .to_return(status: 404, body: { error: 'CEP não encontrado' }.to_json)
      end

      it 'retorna erro' do
        resultado = described_class.buscar(cep)
        expect(resultado).to eq({ error: 'CEP não encontrado' })
      end
    end

    context 'com erro de rede' do
      let(:cep) { '89010025' }

      before do
        stub_request(:get, "https://brasilapi.com.br/api/cep/v2/#{cep}")
          .to_raise(StandardError.new('Network error'))
      end

      it 'retorna erro genérico' do
        resultado = described_class.buscar(cep)
        expect(resultado).to eq({ error: 'Erro ao consultar CEP' })
      end
    end
  end
end
