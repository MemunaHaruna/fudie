Rails.application.routes.draw do

  root 'home#index'

  resources :flags

  namespace :admin do
    resources :flags
  end

  resources :thread_followings, only: [:create, :destroy]
  resources :categories
  resources :bookmarks
  resources :votes

  resources :posts do
    get 'drafts', on: :collection
    get 'hidden', on: :collection
    put 'recover', to: 'posts#recover', on: :member

    resources :votes, only: [:create, :update]
  end
  post 'signup', to: 'users#create'
  post 'signin', to: 'authentication#signin'

  resources :users do
    get 'published-posts', on: :member, to: 'posts#public_posts_per_user'
    put 'recover', to: 'users#recover', on: :member
  end

  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:create, :edit, :update]


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
