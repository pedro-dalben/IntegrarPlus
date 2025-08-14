# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Professionals', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/admin/professionals/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      get '/admin/professionals/show'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /new' do
    it 'returns http success' do
      get '/admin/professionals/new'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /create' do
    it 'returns http success' do
      get '/admin/professionals/create'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /edit' do
    it 'returns http success' do
      get '/admin/professionals/edit'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /update' do
    it 'returns http success' do
      get '/admin/professionals/update'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /destroy' do
    it 'returns http success' do
      get '/admin/professionals/destroy'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /resend_confirmation' do
    it 'returns http success' do
      get '/admin/professionals/resend_confirmation'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /send_reset_password' do
    it 'returns http success' do
      get '/admin/professionals/send_reset_password'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /force_confirm' do
    it 'returns http success' do
      get '/admin/professionals/force_confirm'
      expect(response).to have_http_status(:success)
    end
  end
end
