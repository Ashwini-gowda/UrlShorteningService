class UrlShortenersController < ApplicationController
  before_action :set_url_shortener, only: [:show, :edit, :update, :destroy]

  # GET /url_shorteners or /url_shorteners.json
  def index
    @url_shorteners = UrlShortener.page(params[:page]).per(50)
  end

  # GET /url_shorteners/1 or /url_shorteners/1.json
  def show
  end

  # GET /url_shorteners/new
  def new
    @url_shortener = UrlShortener.new
  end

  # GET /url_shorteners/1/edit
  def edit
  end


  def create
    @url_shortener = UrlShortener.find_or_create_by(url_shortener_params)
    if @url_shortener.persisted?
      @url_shortener.update(short: @url_shortener.short)
      flash[:notice] = "Shortened URL: #{request.base_url}/#{@url_shortener.short}"
      redirect_to url_shortener_url(@url_shortener)
    else
      flash[:alert] = @url.errors.full_messages.to_sentence
      render :new
    end
  end

  # PATCH/PUT /url_shorteners/1 or /url_shorteners/1.json
  def update
    respond_to do |format|
      @url_shortener.short = SecureRandom.alphanumeric(6)
      if @url_shortener.update(original: params[:url_shortener][:original], short: @url_shortener.short)
        format.html { redirect_to @url_shortener, notice: "Url shortener was successfully updated." }
        format.json { render :show, status: :ok, location: @url_shortener }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @url_shortener.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /url_shorteners/1 or /url_shorteners/1.json
  def destroy
    @url_shortener.destroy!

    respond_to do |format|
      format.html { redirect_to url_shorteners_path, status: :see_other, notice: "Url shortener was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def redirect
    url_shortener = UrlShortener.find_by(short: params[:short_url])
    if url_shortener
      redirect_to url_shortener.original, allow_other_host: true
    else
      render plain: "URL not found", status: :not_found
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_url_shortener
      @url_shortener = UrlShortener.find_by(id: params[:id])
    end

    # Only allow a list of trusted parameters through.
    def url_shortener_params
      params.expect(url_shortener: [ :original, :short ])
    end

    def short_url(short_code)
      request.base_url + "/" + short_code
    end
  
end
