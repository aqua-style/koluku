Rails.application.routes.draw do
    root to: 'toppages#index'


    resources :shops, only: [:index, :new, :show, :create]  do 
        member do 
            get :kuchikomi
            post :kuchikomi_post
          #  patch 'mng-hensyu', to: :mng_hensyu
        end
    end


  get 'signup', to: 'users#new'
  resources :users, only: [:index, :show, :create, :edit, :update]

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  
  post 'upload', to: 'shop_photos#upload'
  
  get 'koluku-mng-login', to: 'sessions#mngsessionnew'
  post 'koluku-mng-login', to: 'sessions#mngcreate'
  delete 'koluku-mng-logout', to: 'sessions#mngdestroy'
  resources :managers, only: [:show]
  get 'shop-hensyu', to: 'managers#shop_hensyu'
  patch 'mng-shop-hensyu', to: 'shops#mng_shop_hensyu'
  
  get 'info/about', to: 'info#about'
  get 'info/privacy-policy', to: 'info#privacy_policy'
  get 'info/tokusho', to: 'info#tokusho'
  get 'info/usage', to: 'info#usage'
  get 'info/icon', to: 'info#icon'
  get 'info/sitemap', to: 'info#sitemap'
  
  get 'special/ikebukuro', to: 'special#ikebukuro'
  
  
  
end