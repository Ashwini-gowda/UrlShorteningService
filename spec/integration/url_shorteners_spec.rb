require 'swagger_helper'

RSpec.describe 'UrlShorteners API', type: :request do
  path '/api/v1/url_shorteners' do
    post 'Creates a shortened URL' do
      tags 'UrlShorteners'
      consumes 'application/json'
      security [ { BearerAuth: [] } ]

      parameter name: :url_shortener, in: :body, schema: {
        type: :object,
        properties: {
          original: { type: :string, example: 'https://localhost:8020' }
        },
        required: ['original']
      }

      response '201', 'shortened URL created' do
        let(:Authorization) { 'eyJzdWIiOjEsImV4cCI6MTk3NDU5ODgyNjh9lEIDTiijzswIYKAYKhc6EaLpVpJ0A' }
        let(:url_shortener) { { original: 'https://example.com' } }
        
        run_test! do |response|
          # Check if the response includes the short_url key in the response body
          expect(response.body).to include('short_url')
          
          # Optionally, you can check the structure of the returned short_url
          json_response = JSON.parse(response.body)
          expect(json_response['short_url']).to match(/^http.*\/[a-zA-Z0-9]{6}$/) # Regular expression to match short URL pattern
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'invalid_token' }
        let(:url_shortener) { { original: 'https://example.com' } }
  
        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eq('Unauthorized')
        end
      end

      response '422', 'invalid URL' do
        let(:Authorization) { 'eyJzdWIiOjEsImV4cCI6MTk3NDU5ODgyNjh9lEIDTiijzswIYKAYKhc6EaLpVpJ0A' }
        let(:url_shortener) { { original: '' } }
        run_test!
      end
    end
  end

  path '/api/v1/url_shorteners' do
    # GET request for listing shortened URLs
    get 'Lists all shortened URLs' do
      tags 'UrlShorteners'
      produces 'application/json'

      response '200', 'successful retrieval of shortened URLs' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              original: { type: :string, example: 'https://example.com' },
              short: { type: :string, example: 'http://localhost:3000/M2rckK' },
              created_at: { type: :string, example: '2024-11-27T01:00:00Z' },
              updated_at: { type: :string, example: '2024-11-27T01:00:00Z' }
            }
          }

        let!(:url_shorteners) { create_list(:url_shortener, 3) }

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response.length).to eq(3) # Check if 3 records are returned
          expect(json_response.first).to have_key('short') # Ensure 'short' key is present in response
        end
      end

      response '404', 'no URL shorteners found' do
        let!(:url_shorteners) { [] }

        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response).to eq([]) # Empty array if no records are found
        end
      end
    end
  end

  path '/api/v1/url_shorteners/{id}' do
    put 'Updates a shortened URL' do
      tags 'UrlShorteners'
      consumes 'application/json'
      produces 'application/json'
  
      parameter name: :id, in: :path, type: :integer, description: 'ID of the URL Shortener'
      parameter name: :url_shortener, in: :body, schema: {
        type: :object,
        properties: {
          original_url: { type: :string, example: 'https://updated-example.com' }
        },
        required: ['original_url']
      }
  
      response '200', 'shortened URL updated' do
        let(:id) { UrlShortener.create(original: 'https://example.com', short: 'http://localhost:3000/abc123').id }
        let(:url_shortener) { { original_url: 'https://updated-example.com' } }
  
        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['short_url']).to eq('http://localhost:3000/abc123') # Adjusted URL
        end
      end
  
      response '404', 'URL Shortener not found' do
        let(:id) { 0 }
        let(:url_shortener) { { original_url: 'https://updated-example.com' } }
  
        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq('URL Shortener not found')
        end
      end
  
      response '422', 'validation errors' do
        let(:id) { UrlShortener.create(original: 'https://example.com', short: 'http://localhost:3000/abc123').id }
        let(:url_shortener) { { original_url: '' } } # Invalid URL
  
        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['errors']).to include("Original can't be blank") # Example validation message
        end
      end
    end
  end
  

  path '/api/v1/url_shorteners/{id}' do
    delete 'Deletes a shortened URL' do
      tags 'UrlShorteners'
      produces 'application/json'
  
      parameter name: :id, in: :path, type: :integer, description: 'ID of the URL Shortener'
  
      response '200', 'URL Shortener deleted' do
        let(:id) { UrlShortener.create(original: 'https://example.com', short: 'http://localhost:3000/abc123').id }
        
        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq('URL Shortener successfully deleted')
        end
      end
  
      response '404', 'URL Shortener not found' do
        let(:id) { 0 } # Non-existent ID
  
        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq('URL Shortener not found')
        end
      end
  
      response '422', 'failed to delete URL Shortener' do
        # Example case if additional constraints prevent deletion
        let(:id) { UrlShortener.create(original: 'https://example.com', short: 'http://localhost:3000/abc123').id }
        before { allow_any_instance_of(UrlShortener).to receive(:destroy).and_return(false) }
  
        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq('Failed to delete URL Shortener')
        end
      end
    end
  end

  path '/api/v1/url_shorteners/{id}' do
    get 'Fetches details of a specific shortened URL' do
      tags 'UrlShorteners'
      produces 'application/json'
  
      parameter name: :id, in: :path, type: :integer, description: 'ID of the URL Shortener'
  
      response '200', 'URL Shortener details fetched successfully' do
        let(:id) { UrlShortener.create(original: 'https://example.com', short: 'http://localhost:3000/abc123').id }
        
        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['original_url']).to eq('https://example.com')
          expect(json_response['short_url']).to eq('http://localhost:3000/abc123')
        end
      end
  
      response '404', 'URL Shortener not found' do
        let(:id) { 0 } # Non-existent ID
  
        run_test! do |response|
          json_response = JSON.parse(response.body)
          expect(json_response['message']).to eq('URL Shortener not found')
        end
      end
    end
  end
  
end
