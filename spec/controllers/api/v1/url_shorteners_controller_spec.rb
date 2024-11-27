# spec/controllers/api/v1/url_shorteners_controller_spec.rb
require 'rails_helper'

RSpec.describe Api::V1::UrlShortenersController, type: :controller do
  let(:valid_token) { Rails.application.credentials.auth[:secret_token] }
  let(:invalid_token) { 'invalid_token' }
  let(:headers) { { "Authorization" => valid_token } }
  let(:invalid_headers) { { "Authorization" => invalid_token} }
  let!(:url_shortener) { create(:url_shortener) }

  # Mock authentication
  before do
    allow(controller).to receive(:authenticate_request).and_return(true)
  end

  # Index action test
  describe 'GET #index' do
    context 'with valid authentication' do
      before { request.headers.merge!(headers) }

      it 'returns a successful response' do
        get :index, format: :json
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # Show action test
  describe 'GET #show' do
    context 'when the URL shortener exists' do
      before { request.headers.merge!(headers) }

      it 'returns a successful response' do
        get :show, params: { id: url_shortener.id }
        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct URL shortener details' do
        get :show, params: { id: url_shortener.id }
        json_response = JSON.parse(response.body)
        expect(json_response['original_url']).to eq(url_shortener.original)
        expect(json_response['short_url']).to eq(url_shortener.short)
      end
    end

    context 'when the URL shortener does not exist' do
      before { request.headers.merge!(headers) }

      it 'returns a not found response' do
        get :show, params: { id: 'nonexistent' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # Create action test
  describe 'POST #create' do
    let(:valid_params) { { original: 'http://new-url.com' } }
    let(:invalid_params) { { original: '' } }

    context 'with valid parameters' do
      before { request.headers.merge!(headers) }

      it 'creates a new URL shortener' do
        expect {
          post :create, params: valid_params
        }.to change(UrlShortener, :count).by(1)
      end

      it 'returns a created status' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end

    end

    context 'with invalid parameters' do
      before { request.headers.merge!(headers) }

      it 'does not create a new URL shortener' do
        expect {
          post :create, params: invalid_params
        }.not_to change(UrlShortener, :count)
      end

      it 'returns an error message' do
        post :create, params: invalid_params
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('something went wrong.')
        expect(json_response['errors']).to include("Original can't be blank")
      end
    end
  end

  # Update action test
  describe 'PUT #update' do
    let(:new_url) { 'http://updated-url.com' }

    context 'when the URL shortener exists' do
      before { request.headers.merge!(headers) }

      it 'updates the URL shortener' do
        put :update, params: { id: url_shortener.id, original: new_url }
        url_shortener.reload
        expect(url_shortener.original).to eq(new_url)
      end

      it 'returns a successful response' do
        put :update, params: { id: url_shortener.id, original: new_url }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the URL shortener does not exist' do
      before { request.headers.merge!(headers) }

      it 'returns a not found response' do
        put :update, params: { id: 'nonexistent', original: new_url }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # Destroy action test
  describe 'DELETE #destroy' do
    context 'when the URL shortener exists' do
      before { request.headers.merge!(headers) }

      it 'deletes the URL shortener' do
        expect {
          delete :destroy, params: { id: url_shortener.id }
        }.to change(UrlShortener, :count).by(-1)
      end

      it 'returns a success message' do
        delete :destroy, params: { id: url_shortener.id }
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('URL Shortener successfully deleted')
      end
    end

    context 'when the URL shortener does not exist' do
      before { request.headers.merge!(headers) }

      it 'returns a not found response' do
        delete :destroy, params: { id: 'nonexistent' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
