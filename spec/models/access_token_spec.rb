require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  describe '#validations' do
    let(:user) { create :user }

    it 'should have valid factory' do
      access_token = build :access_token, user: user
      expect(access_token).to be_valid
    end

    it 'should validate presence of attributes' do
      access_token = build :access_token, token: nil, user: nil
      expect(access_token).not_to be_valid
      expect(access_token.errors.messages[:token]).to include("can't be blank")
      expect(access_token.errors.messages[:user]).to include("can't be blank")
    end

    it 'should validate associations' do
      expect(AccessToken.reflect_on_association(:user).macro).to eq(:belongs_to)
    end
  end

  describe '#new' do
    let(:user) { create :user }

    it 'should have a token present after initialize' do
      expect(AccessToken.new.token).to be_present
    end

    it 'should generate unique token' do
      expect { user.create_access_token }.to change { AccessToken.count }.by(1)
      expect (user.build_access_token).to be_valid
    end
  end
end
