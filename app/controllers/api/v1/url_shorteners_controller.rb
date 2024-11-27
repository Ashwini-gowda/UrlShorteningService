class Api::V1::UrlShortenersController < ApplicationController 
    before_action :authenticate_request, only: [:index, :show, :create, :update, :destroy]
    skip_before_action :verify_authenticity_token, only: [:create, :update, :destroy]

    def index
      page_size = params[:page_size] || 50
      page = params[:page] || 1
      @url_shorteners = UrlShortener.all.page(page).per(page_size)
      respond_to do |format|
        format.json { render json: @url_shorteners }  # Explicitly render JSON
      end
    end

    def create
      @url_shortener = UrlShortener.new(original: params[:original])
      if @url_shortener.save
        @url_shortener.update(short: @url_shortener.short)
        puts @url_shortener.inspect
        render json: { short_url: "#{request.base_url}/#{@url_shortener.short}" }, status: :created
      else
        render json: {
          success: false,
          message: "something went wrong.",
          errors: @url_shortener.errors.full_messages
        }
      end
    end

    def update
      @url_shortener = UrlShortener.find_by(id: params[:id])
      if @url_shortener.nil?
        render json: { success: false, message: 'URL Shortener not found' }, status: :not_found
        return
      end
      @url_shortener.short = SecureRandom.alphanumeric(6)
      if @url_shortener.update(original: params[:original], short: @url_shortener.short)
        render json: {"#{request.base_url}/#{@url_shortener.short}" }, status: :ok
      else
        render json: {
          success: false,
          message: "something went wrong.",
          errors: @url_shortener.errors.full_messages
        }
      end
    end


    def destroy
      @url_shortener = UrlShortener.find_by(id: params[:id])
      if @url_shortener.nil?
        render json: { success: false, message: 'URL Shortener not found' }, status: :not_found
      elsif @url_shortener.destroy
        render json: { success: true, message: 'URL Shortener successfully deleted' }, status: :ok
      else
        render json: { success: false, message: 'Failed to delete URL Shortener', errors: @url_shortener.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def show
      @url_shortener = UrlShortener.find_by(id: params[:id])
      if @url_shortener
        render json: { 
          id: @url_shortener.id,
          original_url: @url_shortener.original,
          short_url: @url_shortener.short
        }, status: :ok
      else
        render json: { success: false, message: "URL Shortener not found" }, status: :not_found
      end
    end

    private

    def authenticate_request
      token = request.headers["Authorization"]
      puts "Authorization Header: #{token}"
      if token.present?
        secret_token = Rails.application.credentials.auth[:secret_token]
        render json: { error: "Unauthorized" }, status: :unauthorized if token != secret_token
      else
        render json: { error: "Unauthorized: Missing Authorization header" }
      end
    end
  end
