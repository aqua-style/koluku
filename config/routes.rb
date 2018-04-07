Rails.application.routes.draw do
    root to: 'toppages#index'

    #メンタリングで聞く
    resources :shops, only: [:index, :new, :show, :create]  do 
        member do 
            get :kuchikomi
            post :kuchikomi_post
        end
    end

end