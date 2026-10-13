require 'rails_helper'

RSpec.describe 'Api::V1::Classrooms', type: :request do
  let!(:admin) do
    User.find_by(email: 'admin@elearning.test') ||
      User.create!(name: 'Admin', email: 'admin@elearning.test', password: 'password123', role: 'ROLE_ADMIN')
  end
  let!(:classroom) { Classroom.find_by(name: '10-A') || Classroom.create!(name: '10-A', level: 10, capacity: 36, academic_year: '2025/2026') }

  describe 'GET /api/v1/classrooms' do
    it 'returns list of classrooms' do
      get '/api/v1/classrooms', headers: auth_headers_for(admin)

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['success']).to be true
      expect(body['data']).to be_an(Array)
      expect(body['data'].any? { |c| c['name'] == '10-A' }).to be true
    end
  end

  describe 'POST /api/v1/classrooms' do
    it 'creates a new classroom' do
      post '/api/v1/classrooms', params: { classroom: { name: '10-B', level: 10, capacity: 36, academic_year: '2025/2026' } }, headers: auth_headers_for(admin), as: :json

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body['data']['name']).to eq('10-B')
    end
  end
end
