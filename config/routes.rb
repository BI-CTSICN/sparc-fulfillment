Rails.application.routes.draw do
  devise_for :users
  mount API::Base => '/'
  root 'protocols#index'

  resources :protocols do
    collection do
      resources :arms do
        member do
          get 'change'
        end
      end
    end

    member do
      get 'change_arm'
    end
    resources :participants
    
    resources :service_calendar
  end

end



