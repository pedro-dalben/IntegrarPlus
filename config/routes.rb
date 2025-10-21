# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations'
  }

  root 'home#index'

  namespace :admin do
    root 'dashboard#index'

    resources :news

    resources :professionals do
      member do
        patch :activate
        patch :deactivate
        patch :confirm
        patch :unconfirm
      end
    end

    resources :groups do
      member do
        patch :activate
        patch :deactivate
      end
    end

    resources :specialties do
      member do
        patch :activate
        patch :deactivate
      end
    end

    resources :specializations do
      member do
        patch :activate
        patch :deactivate
      end
    end

    resources :contract_types do
      member do
        patch :activate
        patch :deactivate
      end
    end

    resources :documents do
      member do
        patch :activate
        patch :deactivate
        patch :approve
        patch :reject
      end
    end

    resources :document_permissions do
      member do
        patch :activate
        patch :deactivate
      end
    end

    resources :document_releases do
      member do
        patch :activate
        patch :deactivate
      end
    end

    resources :portal_intakes do
      member do
        patch :activate
        patch :deactivate
        get :schedule_anamnesis
        post :schedule_anamnesis
        get :agenda_view
      end
    end

    resources :beneficiaries do
      member do
        patch :activate
        patch :deactivate
      end
      collection do
        get :search
      end
      resources :anamneses, except: [:index]
    end

    resources :anamneses, only: %i[index show] do
      member do
        patch :complete
      end
      collection do
        get :today
        get :by_professional
        get :professionals
      end
    end

    # Busca de escolas
    resources :schools, only: [] do
      collection do
        get :search
      end
    end

    resources :agendas do
      member do
        patch :activate
        patch :deactivate
        patch :archive
        patch :duplicate
        get :preview_slots
      end
      collection do
        get :search_professionals
        get :preview_slots
        post :configure_schedule
      end
    end

    resources :agenda_templates do
      member do
        patch :activate
        patch :deactivate
      end
    end

    resources :medical_appointments do
      member do
        patch :cancel
        patch :reschedule
        patch :complete
        patch :mark_no_show
      end

      resources :appointment_notes, except: %i[index show]
      resources :appointment_attachments, except: %i[index show] do
        member do
          get :download
        end
      end

      collection do
        get :reports
        get :professional_report
      end
    end

    resources :permissions do
      member do
        patch :activate
        patch :deactivate
      end
    end

    resources :users do
      member do
        patch :activate
        patch :deactivate
      end
      collection do
        get :search
      end
      resources :invites, only: %i[index create show destroy] do
        member do
          post :resend
        end
      end
    end

    resources :external_users do
      member do
        patch :activate
        patch :deactivate
      end
      collection do
        get :search
      end
    end

    get 'agenda_dashboard', to: 'agenda_dashboard#index'

    resources :notifications do
      member do
        post :mark_as_read
        post :mark_as_unread
      end
      collection do
        post :mark_all_as_read
        get :unread_count
        get :preferences
        patch :update_preferences
        get :templates
        post :create_default_templates
      end
    end

    resources :notification_templates, path: 'notifications/templates', except: [:show] do
      member do
        patch :activate
        patch :deactivate
      end
    end

    resources :workspace, only: [:index]
    resources :released_documents, only: %i[index show]
    resources :specialities, except: [:show]
    resources :calendar, only: [:index]
  end

  namespace :api do
    resources :professionals, only: %i[index show] do
      collection do
        get :search
      end
      member do
        get :availability
      end
    end
  end

  namespace :portal do
    root 'portal_intakes#index'

    get 'sign_in', to: 'sessions#new', as: :new_external_user_session
    post 'sign_in', to: 'sessions#create'
    delete 'sign_out', to: 'sessions#destroy', as: :destroy_external_user_session

    get 'password/new', to: 'passwords#new', as: :new_external_user_password
    post 'password', to: 'passwords#create'
    get 'password/edit', to: 'passwords#edit', as: :edit_external_user_password
    patch 'password', to: 'passwords#update'

    resources :portal_intakes do
      member do
        get :schedule_anamnesis
        post :schedule_anamnesis
      end
    end
  end

  get 'cep/:cep', to: 'cep#search', as: :buscar_cep

  get 'invite/:token', to: 'invites#show', as: :invite
  post 'invite/:token/accept', to: 'invites#accept', as: :accept_invite_post

  get 'up' => 'rails/health#show', as: :rails_health_check
end
