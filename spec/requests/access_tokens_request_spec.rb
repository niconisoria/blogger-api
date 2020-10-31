require 'rails_helper'

RSpec.describe 'AccessTokens', type: :request do
  describe '#create' do
    let(:create) { '/login' }

    context 'when no oauth_data provided' do
      subject { post create }
      it_behaves_like 'unauthorized_standard_requests'
    end

    context 'when invalid code provided' do
      let(:github_error) { double('Sawyer::Resource', error: 'bad_verification_code') }

      before do
        allow_any_instance_of(Octokit::Client).to receive(:exchange_code_for_token).and_return(github_error)
      end

      subject { post create, params: { code: 'invalid_code' } }

      it_behaves_like 'unauthorized_oauth_requests'
    end

    context 'when success request' do
      let(:user_data) do
        {
          login: 'JDoo1',
          url: 'http://example.com',
          avatar_url: 'http://example.com/avatar',
          name: 'John Doo'
        }
      end

      before do
        allow_any_instance_of(Octokit::Client).to receive(:exchange_code_for_token).and_return('validaccesstoken')

        allow_any_instance_of(Octokit::Client).to receive(:user).and_return(user_data)
      end

      subject { post create, params: { code: 'valid_code' } }

      it 'should return 201 status code' do
        subject
        expect(response).to have_http_status(:created)
      end

      it 'should return proper json' do
        expect { subject }.to change { User.count }.by(1)
        user = User.find_by(login: 'JDoo1')
        expect(json_data['attributes']).to eq({ 'token' => user.access_token.token })
      end
    end
  end

  describe '#destroy' do
    let(:destroy) { '/logout' }

    context 'when no authorization header provided' do
      subject { delete destroy }
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid authorization header provided' do
      subject { delete destroy, headers: { 'Authorization' => 'invalid_token' } }
      it_behaves_like 'forbidden_requests'
    end

    context 'when valid request' do
      let(:user) { create :user }
      let!(:access_token) { user.create_access_token }

      subject { delete destroy, headers: { 'Authorization' => "Bearer #{access_token.token}" } }

      it 'should return 204 status code' do
        subject
        expect(response).to have_http_status(:no_content)
      end

      it 'should remove the proper access token' do
        expect { subject }.to change { AccessToken.count }.by(-1)
      end
    end
  end
end
