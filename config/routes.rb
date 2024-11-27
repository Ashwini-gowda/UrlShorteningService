Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  root 'url_shorteners#new'
  resources :url_shorteners
  get "/:short_url", to: "url_shorteners#redirect", as: :short

  namespace :api do
    namespace :v1 do
      resources :url_shorteners, only: [:show, :index, :create, :update, :destroy]
    end
  end
end
