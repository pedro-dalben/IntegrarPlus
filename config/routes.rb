# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resource :avatar, only: %i[update destroy]

  # Rotas para convites
  get 'invite/:token', to: 'invites#show', as: :invite
  post 'invite/:token/accept', to: 'invites#accept', as: :accept_invite

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
        post :create_user
      end
    end

    resources :users, except: [:index] do
      member do
        patch :activate
        patch :deactivate
      end
      resources :invites, only: %i[index create]
    end

    resources :invites, only: %i[show destroy] do
      member do
        patch :resend
      end
    end

    resources :specialities
    resources :specializations do
      collection do
        get :by_speciality, defaults: { format: :json }
      end
    end
    resources :contract_types
    resources :groups
    get '/', to: 'dashboard#index'
    get '/ui', to: 'ui#index'
  end
end
