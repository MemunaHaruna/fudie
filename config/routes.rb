Rails.application.routes.draw do

  resources :categories
  resources :bookmarks
  resources :votes
  get 'posts/drafts', to: 'posts#drafts'
  get 'posts/hidden', to: 'posts#hidden'
  get 'posts/:user_id/public', to: 'posts#public_posts_per_user'

  resources :posts do
    resources :votes, only: [:create, :update]
  end
  post 'signup', to: 'users#create'
  post 'signin', to: 'authentication#signin'

  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:create, :edit, :update]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
