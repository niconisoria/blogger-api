require 'rails_helper'

describe "articles routes" do
    it "should route to index" do
        expect(get '/articles').to route_to('articles#index')  
    end

    it "should route to show" do
        expect(get '/articles/1').to route_to('articles#show', id: '1')  
    end

    it 'should route to create' do
        expect(post '/articles').to route_to('articles#create')
    end

    it 'should route to update' do
        expect(put '/articles/1').to route_to('articles#update', id: '1')
        expect(patch '/articles/1').to route_to('articles#update', id: '1')
    end
end