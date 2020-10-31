require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe '#create' do
    let(:sign_up) { '/sign_up' }
    subject { post sign_up, params: params }

    context 'when invalid data provided' do
      let(:params) do
        {
          data: {
            attributes: {
              login: nil,
              password: nil
            }
          }
        }
      end

      it 'should return 422 status code' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'should not create a user' do
        expect { subject }.not_to change { User.count }
      end

      it 'should return proper json' do
        subject
        expect(json['errors']).to include(
          {
            'source' => { 'pointer' => '/data/attributes/login' },
            'detail' => "can't be blank"
          },
          {
            'source' => { 'pointer' => '/data/attributes/password' },
            'detail' => "can't be blank"
          }
        )
      end
    end

    context 'when valid data provided' do
      let(:params) do
        {
          data: {
            attributes: {
              login: 'JDoo',
              password: 'secret'
            }
          }
        }
      end

      it 'should return 201 status code' do
        subject
        expect(response).to have_http_status(:created)
      end

      it 'should create an user' do
        expect(User.exists?(login: 'JDoo')).to be_falsey
        expect { subject }.to change { User.count }.by(1)
        expect(User.exists?(login: 'JDoo')).to be_truthy
      end
    end
  end
end
