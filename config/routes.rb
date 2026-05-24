# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  mount ActionCable.server => "/cable"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  unless Rails.env.production?
    mount Rswag::Ui::Engine => "/api-docs"
    mount Rswag::Api::Engine => "/api-docs"
  end

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      resource :signup, only: :create
      resource :session, only: %i[create destroy]
      resource :me, only: :show, controller: :me
      resources :comments, only: %i[index create update destroy]
      resources :users, only: :index
      resources :notifications, only: :index do
        collection do
          get :unread_count
          patch :mark_all_as_read
        end
        member do
          patch :mark_as_read
        end
      end
    end
  end
end
