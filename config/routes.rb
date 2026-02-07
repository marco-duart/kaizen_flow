Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  get "up" => "rails/health#show", as: :rails_health_check

  mount_devise_token_auth_for "User", at: "api/v1/auth"

  namespace :api do
    namespace :v1 do
      get "health", to: "health#check"

      resources :companies
      resources :units
      resources :rooms
      resources :networks
      resources :departments
      resources :teams
      resources :groups
      resources :roles do
        resources :permissions
      end
      resources :users
      resources :ticket_categories do
        resources :slas
        resources :ticket_custom_fields
      end
      resources :ticket_statuses
      resources :ticket_priorities
      resources :tickets do
        resources :comments
        resources :tasks, controller: "ticket_tasks"
        resources :links, controller: "ticket_links"
        resources :histories, controller: "ticket_histories", only: [ :index ]
      end
      resources :ticket_schedules
      resources :item_categories
      resources :items do
        resources :stock_records
      end
      resources :devices
      resources :loans
      resources :satisfaction_surveys
    end
  end
end
