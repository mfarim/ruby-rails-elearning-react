require 'rails_helper'

RSpec.describe UserRepository, type: :model do
  let(:repo) { described_class.new }
  let!(:user) { User.create!(name: 'Admin Test', email: 'admin@repo-test.com', password: 'password123', role: 'ROLE_ADMIN') }

  describe '#find_by_email' do
    it 'finds user by email' do
      found = repo.find_by_email('admin@repo-test.com')
      expect(found).to eq(user)
    end

    it 'returns nil for unknown email' do
      expect(repo.find_by_email('unknown@email.com')).to be_nil
    end
  end

  describe '#find_admin' do
    it 'returns an admin user' do
      admin = repo.find_admin
      expect(admin).to be_present
      expect(admin.role).to eq('ROLE_ADMIN')
    end
  end
end
