Rails.application.routes.draw do
  resources :socratic_seminars, path: 'seminars' do
    resources :topics, path: 'topics' do 
      member do
        post 'upvote'
        post 'downvote'
      end
      
      collection do
        post 'import_sections_and_topics'
      end
    end
    
    member do
      delete 'delete_sections'
    end
  end

  # Admin mode control
  post 'seminars/disable_admin_mode', to: 'socratic_seminars#disable_admin_mode_action', as: :disable_admin_mode

  get "webhook/receive"

  # LNURL Pay
  get '/lnurl-pay/:id', to: 'lnurl_pay#show', as: :lnurl_pay
  get '/lnurl-callback', to: 'lnurl_callback#show' # Doesn't need /:id as the params {id: XX} is passed in from the LNURL callback
  post 'webhook', to: 'webhook#create'

  post 'webhook/receive', to: 'webhook#receive'

  root "socratic_seminars#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
