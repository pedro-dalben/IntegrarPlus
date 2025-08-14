# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::ContractTypes', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/admin/contract_types/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /new' do
    it 'returns http success' do
      get '/admin/contract_types/new'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /create' do
    it 'returns http success' do
      get '/admin/contract_types/create'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /edit' do
    it 'returns http success' do
      get '/admin/contract_types/edit'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /update' do
    it 'returns http success' do
      get '/admin/contract_types/update'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /destroy' do
    it 'returns http success' do
      get '/admin/contract_types/destroy'
      expect(response).to have_http_status(:success)
    end
  end
end
