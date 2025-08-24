require 'rails_helper'

RSpec.describe 'Admin::ProfessionalPermissions', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/admin/professional_permissions/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /update' do
    it 'returns http success' do
      get '/admin/professional_permissions/update'
      expect(response).to have_http_status(:success)
    end
  end
end
