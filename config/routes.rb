Rails.application.routes.draw do
  # Mission Control Jobs UI — gated to signed-in admins via the app session
  # (see AdminSessionConstraint). Non-admins never match the route (404).
  constraints(AdminSessionConstraint) do
    mount MissionControl::Jobs::Engine, at: "/admin/jobs"
  end

  # Authentication routes
  get "/login", to: "sessions#new", as: :new_session
  post "/login", to: "sessions#create", as: :session
  delete "/logout", to: "sessions#destroy", as: :logout

  # Root redirects to login
  root to: redirect("/login")

  resources :passwords, param: :token

  get "signup", to: "registrations#new", as: :new_registration
  resource :registration, only: [ :create ], path: "signup" do
    patch :update_personal_data, on: :collection
    patch :update_anamnese, on: :collection
    patch :finalize, on: :collection
  end

  get "check_email", to: "registrations#check_email"

  # Admin namespace
  namespace :admin do
    get "dashboard", to: "dashboard#index", as: :dashboard
    resources :users, except: [ :index ] do
      member do
        patch :deactivate
        patch :activate
      end
    end
    resources :students, except: [ :index ] do
      resources :videos
      collection do
        get :search
        get :autocomplete
      end
    end
    resources :trainings do
      member do
        patch :toggle_active
      end
      collection do
        get :search_exercises
        get :autocomplete
        get :autocomplete_with_inactive
      end
    end
    resources :nutrition_plans do
      member do
        patch :toggle_active
      end
      collection do
        get :search
        get :meal_field
      end
    end
    resources :foods do
      collection do
        get :categories
        get :search
      end
    end
    resources :strength_exercises, only: [ :show, :create, :update, :destroy ] do
      collection do
        get :search
      end
    end
    resources :mobility_exercises, only: [ :show, :create, :update, :destroy ] do
      collection do
        get :search
      end
    end
    resources :core_exercises, only: [ :show, :create, :update, :destroy ] do
      collection do
        get :search
      end
    end
    resources :cardio_exercises, only: [ :show, :create, :update, :destroy ] do
      collection do
        get :search
      end
    end
    resources :videos, only: [ :index, :create, :update, :destroy ]
    resources :evaluation_media, only: [ :index, :show, :update, :destroy ]
    resources :pending_registrations, only: [ :index, :destroy ] do
      member do
        get :details
        post :approve
        post :reject
        post :reset
      end
    end
    resources :notifications, only: [] do
      collection do
        post :bulk_send
      end
      member do
        patch :mark_as_read
      end
    end
    post "notifications/mark_all_as_read", to: "notifications#mark_all_as_read", as: :mark_all_notifications_as_read
  end

  # Student namespace
  namespace :student do
    get "dashboard", to: "dashboard#index", as: :dashboard
    get "profile/edit", to: "profile#edit", as: :edit_profile
    patch "profile", to: "profile#update", as: :profile
    get "password/edit", to: "password#edit", as: :edit_password
    patch "password", to: "password#update", as: :password
    resources :evaluation_media, only: [ :new, :create ]
    resources :trainings, only: [ :show ]
    resources :nutrition_plans, only: [ :show ]
  end

  # Partner namespace
  namespace :partner do
    get "dashboard", to: "dashboard#index", as: :dashboard
  end

  # Training routes
  # Note: Students can only view training details, no session tracking
  resources :trainings, only: [ :show ]

  # Workout session exercises (authenticated students only)
  resources :workout_session_exercises, only: [] do
    member do
      patch :toggle
    end
  end

  # Exercise API endpoints
  resources :strength_exercises, only: [ :index ]
  resources :mobility_exercises, only: [ :index ]
  resources :core_exercises, only: [ :index ]
  resources :cardio_exercises, only: [ :index ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
