# frozen_string_literal: true

Rails.application.routes.draw do
  resources :organizations do
    member do
      get :settings
    end
    resources :organization_roles, path: "roles", only: [ :create, :destroy ]
  end

  resource :profile, only: [ :show ]
  devise_for :users

  resources :socratic_seminars, path: "seminars" do
    resources :topics, path: "topics" do
      member do
        post "upvote"
        post "downvote"
      end

      collection do
        post "import_sections_and_topics"
      end
    end

    member do
      delete "delete_sections"
    end
  end

  get "webhook/receive"

  # LNURL Pay
  get "/lnurl-pay/:id", to: "lnurl_pay#show", as: :lnurl_pay
  get "/lnurl-callback", to: "lnurl_callback#show" # Doesn't need /:id as the params {id: XX} is passed in from the LNURL callback
  post "webhook", to: "webhook#create"

  post "webhook/receive", to: "webhook#receive"

  post "/toggles/increment", to: "toggles#increment", as: :increment_toggle
  get "/sats_vs_bitcoin", to: "toggles#sats_vs_bitcoin", as: :sats_vs_bitcoin

  root "socratic_seminars#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "/projector", to: "static#projector", as: :projector
end
