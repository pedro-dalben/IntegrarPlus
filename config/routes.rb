# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resource :avatar, only: %i[update destroy]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  authenticated :user do
    root to: 'admin/dashboard#index', as: :authenticated_root
  end

  devise_scope :user do
    unauthenticated do
      root to: 'devise/sessions#new', as: :unauthenticated_root
    end
  end
  get 'styleguide' => 'styleguide#index'

  namespace :admin do
    resource :profile, only: %i[show edit update]

    resources :professionals do
      member do
        post :resend_confirmation
        post :send_reset_password
        post :force_confirm
      end
    end
    resources :specialities
    resources :specializations
    resources :contract_types
    get '/', to: 'dashboard#index'
    get '/ui', to: 'ui#index'
  end
end
