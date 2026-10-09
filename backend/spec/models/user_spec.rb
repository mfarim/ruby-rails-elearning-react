require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.new(name: 'Test User', email: 'test@elearning.test', password: 'password123', role: 'ROLE_STUDENT')
      expect(user).to be_valid
    end

    it 'is invalid without an email' do
      user = User.new(name: 'Test User', password: 'password123', role: 'ROLE_STUDENT')
      expect(user).not_to be_valid
    end

    it 'validates role inclusion' do
      user = User.new(name: 'Test User', email: 'test2@elearning.test', password: 'password123', role: 'INVALID_ROLE')
      expect(user).not_to be_valid
    end
  end

  describe 'role helper methods' do
    it 'correctly identifies admin, teacher, and student' do
      admin = User.new(role: 'ROLE_ADMIN')
      teacher = User.new(role: 'ROLE_TEACHER')
      student = User.new(role: 'ROLE_STUDENT')

      expect(admin.admin?).to be true
      expect(teacher.teacher?).to be true
      expect(student.student?).to be true
    end
  end
end
