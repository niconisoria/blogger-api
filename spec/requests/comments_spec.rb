require 'rails_helper'

RSpec.describe '/comments', type: :request do
  let(:article) { create :article }

  describe 'GET /index' do
    subject { get article_comments_url(article_id: article.id) }

    it 'renders a successful response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return only comments belonging to the specific article' do
      comment = create :comment, article: article
      create :comment
      subject
      expect(json_data.length).to eq(1)
      expect(json_data.first['id']).to eq(comment.id.to_s)
    end

    it 'should paginate results' do
      comments = create_list :comment, 3, article: article
      get article_comments_url(article_id: article.id), params: { per_page: 1, page: 2 }
      expect(json_data.length).to eq(1)
      comment = comments.second
      expect(json_data.first['id']).to eq(comment.id.to_s)
    end

    it 'should have proper json body' do
      comment = create :comment, article: article
      subject
      expect(json_data.first['attributes']).to include(
        {
          'content' => comment.content
        }
      )
    end

    it 'should have related objects information in the response' do
      user = create :user
      create :comment, article: article, user: user
      subject
      relationships = json_data.first['relationships']
      expect(relationships['article']['data']['id']).to eq(article.id.to_s)
      expect(relationships['user']['data']['id']).to eq(user.id.to_s)
    end
  end

  describe 'POST /create' do
    context 'when not authorized' do
      subject { post article_comments_url(article_id: article.id) }
      it_behaves_like 'forbidden_requests'
    end

    context 'when authorized' do
      let(:valid_attributes) {
        { data: { attributes: { content: 'A comment for this article.' } } }
      }
      let(:invalid_attributes) {
        { data: { attributes: { content: '' } } }
      }

      let(:user) { create :user }
      let(:access_token) { user.create_access_token }
      let(:valid_headers) { { 'Authorization' => "Bearer #{access_token.token}" } }

      context 'with valid parameters' do
        subject { post article_comments_url(article_id: article.id), params: valid_attributes, headers: valid_headers }

        it 'should return 201 status code' do
          subject
          expect(response).to have_http_status(:created)
        end

        it 'creates a new comment' do
          expect { subject }.to change(article.comments, :count).by(1)
        end

        it 'renders a JSON response with the new comment' do
          subject
          expect(json_data['attributes']).to eq(
            {
              'content' => 'A comment for this article.'
            }
          )
        end
      end

      context 'with invalid parameters' do
        subject { post article_comments_url(article_id: article.id), params: invalid_attributes, headers: valid_headers }

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not create a new comment' do
          expect { subject }.to change(article.comments, :count).by(0)
        end

        it 'renders a JSON response with errors for the new comment' do
          subject
          expect(json['errors']).to include(
            {
              'source' => { 'pointer' => '/data/attributes/content' },
              'detail' => "can't be blank"
            }
          )
        end
      end
    end
  end
end
