Rails.application.routes.draw do
  resources :comments, except: [:index, :new]

  namespace :admin do
    resources :comments, only: [:index, :show] do
      member do
        post 'toggle', defaults: { format: :json }
        put 'lock', defaults: { format: :json }
        delete 'lock', action: :unlock, defaults: { format: :json }
      end
    end
  end

  namespace :my do
    resources :comments, only: [:index]
  end
end
