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

    resources :agendas do
      member do
        patch :activate
        patch :deactivate
        patch :archive
        patch :duplicate
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
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
