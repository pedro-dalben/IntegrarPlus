# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :external_users, path: 'portal', controllers: {
    sessions: 'portal/sessions',
    passwords: 'portal/passwords'
  }

  get 'workspace/index'
  get 'released_documents/index'
  get 'released_documents/show'
  get 'workspace/index'
  get 'version_comments/create'
  get 'version_comments/update'
  get 'version_comments/destroy'
  get 'document_permissions/index'
  get 'document_permissions/create'
  get 'document_permissions/destroy'

  # Rota pública para teste de busca
  get 'test/search_test', to: 'test#search_test'

  # API para busca de CEP
  get 'cep/:cep', to: 'cep#buscar', as: :buscar_cep

  # Demonstração do componente de CEP
  resources :cep_demo, only: [:index, :create]
  get '/address_demo', to: 'cep_demo#address_demo'

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

  # Rotas para usuários externos (operadoras)
  authenticated :external_user do
    root to: 'portal/service_requests#index', as: :external_user_root
  end

  # Rotas para usuários internos
  authenticated :user do
    root to: 'admin/dashboard#index', as: :authenticated_root
  end

  devise_scope :user do
    unauthenticated do
      root to: 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  # Portal de operadoras
  namespace :portal do
    resources :service_requests do
      resources :service_request_referrals, only: [:create, :destroy], path: 'encaminhamentos'
    end
    resources :portal_intakes, only: [:index, :new, :create, :show]
    root to: 'service_requests#index'
  end
  get 'styleguide' => 'styleguide#index'

  namespace :admin do
    resources :professional_permissions, only: %i[index update]
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
      collection do
        get :search, defaults: { format: :json }
      end
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
    resources :groups do
      collection do
        get :search, defaults: { format: :json }
      end
    end

    resources :released_documents, only: %i[index show]
    get 'workspace', to: 'workspace#index'
    resources :documents do
      member do
        get :download
        post :upload_version
      end

      resources :document_permissions, only: %i[index create destroy]
      resources :version_comments, only: %i[create update destroy]
      resources :document_tasks, except: [:show] do
        member do
          patch :complete
          patch :reopen
        end
      end
      resources :document_status_changes, only: %i[index new create]
      resources :document_responsibles, only: %i[index create destroy]
      resources :document_releases, only: %i[index new create] do
        member do
          get :download
        end
      end
    end

    resources :portal_intakes, only: [:index, :show, :update] do
      member do
        post :schedule_anamnesis
      end
    end

    get '/', to: 'dashboard#index'
    get '/dashboard', to: 'dashboard#index'
    get '/ui', to: 'ui#index'
  end
end
