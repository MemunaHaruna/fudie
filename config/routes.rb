Rails.application.routes.draw do

  post 'signup', to: 'users#create'
  post 'signin', to: 'authentication#signin'

  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:create, :edit, :update]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
