require 'rails_helper'

RSpec.describe Auth::AuthenticateUser do
  let(:use_case) { described_class.new }
  let!(:user) { User.create!(name: 'Teacher One', email: 'teacher@usecase-test.com', password: 'password123', role: 'ROLE_TEACHER') }

  describe '#call' do
    it 'returns success with token payload on valid credentials' do
      result = use_case.call(email: 'teacher@usecase-test.com', password: 'password123')

      expect(result).to be_success
      expect(result.data[:accessToken]).to be_present
      expect(result.data[:userId]).to eq(user.id)
      expect(result.data[:roles]).to include('ROLE_TEACHER')
    end

    it 'returns unauthorized failure on incorrect password' do
      result = use_case.call(email: 'teacher@usecase-test.com', password: 'wrongpassword')

      expect(result).to be_failure
      expect(result.status).to eq(:unauthorized)
      expect(result.error).to eq("Invalid email or password")
    end
  end
end
