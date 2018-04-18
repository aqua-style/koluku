Rails.application.routes.draw do
    root to: 'toppages#index'


    resources :shops, only: [:index, :new, :show, :create]  do 
        member do 
            get :kuchikomi
            post :kuchikomi_post
        end
    end


  get 'signup', to: 'users#new'
  resources :users, only: [:index, :show, :create, :edit, :update]

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  
  post 'upload', to: 'shop_photos#upload'
  
end