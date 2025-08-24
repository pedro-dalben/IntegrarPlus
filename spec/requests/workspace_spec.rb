require 'rails_helper'

RSpec.describe 'Workspaces', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/workspace/index'
      expect(response).to have_http_status(:success)
    end
  end
end
