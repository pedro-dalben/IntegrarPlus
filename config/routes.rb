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

      resources :appointment_notes, except: [:index, :show]
      resources :appointment_attachments, except: [:index, :show] do
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

    get 'agenda_dashboard', to: 'agenda_dashboard#index'
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
