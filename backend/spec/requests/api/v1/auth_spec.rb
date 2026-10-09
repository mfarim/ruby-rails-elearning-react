require 'rails_helper'

RSpec.describe 'Api::V1::Auth', type: :request do
  let!(:user) { User.create!(name: 'Admin Test', email: 'admin@elearning.test', password: 'password123', role: 'ROLE_ADMIN') }

  describe 'POST /api/v1/auth/login' do
    it 'returns JWT access token on valid credentials' do
      post '/api/v1/auth/login', params: { email: 'admin@elearning.test', password: 'password123' }, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['success']).to be true
      expect(body['data']['accessToken']).to be_present
      expect(body['data']['email']).to eq('admin@elearning.test')
    end

    it 'returns unauthorized on invalid password' do
      post '/api/v1/auth/login', params: { email: 'admin@elearning.test', password: 'wrong' }, as: :json

      expect(response).to have_http_status(:unauthorized)
      body = JSON.parse(response.body)
      expect(body['success']).to be false
    end
  end

  describe 'GET /api/v1/auth/me' do
    it 'returns authenticated user profile' do
      headers = auth_headers_for(user)
      get '/api/v1/auth/me', headers: headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['data']['id']).to eq(user.id)
      expect(body['data']['roles']).to include('ROLE_ADMIN')
    end
  end
end
