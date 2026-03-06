Rails.application.routes.draw do
  root to: "assistants#index"

  resources :users, only: [:new, :create, :update]

  resources :assistants do
    resources :messages, only: [:new, :create, :edit]
  end

  resources :conversations, only: [:index, :show, :edit, :update, :destroy] do
    resources :messages, only: [:index]
  end

  get "share/:share_token", to: "conversations#public_show", as: :public_conversation

  resources :messages, only: [:show, :update]

  namespace :settings do
    resources :assistants, except: [:index, :show]
    resource :user, only: [:edit, :update]
    resources :memories, only: [:index, :destroy] do
      delete :destroy, to: "memories#destroy_all", on: :collection
    end
  end

  get "/login", to: "authentications#new"
  post "/login", to: "authentications#create"
  get "/register", to: "users#new"
  get "/logout", to: "authentications#destroy"

  # resources :documents  TODO: finish this feature

  get "/rails/active_storage/postgresql/:encoded_key/*filename" => "active_storage/postgresql#show", as: :rails_postgresql_service
  put "/rails/active_storage/postgresql/:encoded_token" => "active_storage/postgresql#update", as: :update_rails_postgresql_service

  get "up" => "rails/health#show", as: :rails_health_check
end
