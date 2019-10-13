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
  get 'posts/drafts', to: 'posts#drafts'
  get 'posts/hidden', to: 'posts#hidden'
  get 'users/:user_id/published-posts', to: 'posts#public_posts_per_user'

  resources :posts do
    resources :votes, only: [:create, :update]
    put 'recover', to: 'posts#recover', on: :member
  end
  post 'signup', to: 'users#create'
  post 'signin', to: 'authentication#signin'

  resources :users do
    put 'recover', to: 'users#recover', on: :member
  end

  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:create, :edit, :update]


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
