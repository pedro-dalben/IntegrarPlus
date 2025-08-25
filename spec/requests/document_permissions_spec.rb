# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DocumentPermissions', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/document_permissions/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /create' do
    it 'returns http success' do
      get '/document_permissions/create'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /destroy' do
    it 'returns http success' do
      get '/document_permissions/destroy'
      expect(response).to have_http_status(:success)
    end
  end
end
