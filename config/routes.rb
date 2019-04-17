# frozen_string_literal: true

Rails.application.routes.draw do
  resources :comments, only: %i[update destroy]

  scope '/(:locale)', constraints: { locale: /ru|en|sv|cn/ } do
    resources :comments, only: %i[create edit show] do
      post 'check', on: :collection
    end

    namespace :admin do
      resources :comments, only: %i[index show] do
        member do
          post 'toggle', defaults: { format: :json }
          put 'lock', defaults: { format: :json }
          delete 'lock', action: :unlock, defaults: { format: :json }
        end
      end
    end

    namespace :my do
      resources :comments, only: :index
    end
  end
end
