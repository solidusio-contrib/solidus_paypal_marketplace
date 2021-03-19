# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  namespace :admin do
    namespace :sellers do
      resources :prices, path: :offers
      get :paypal_callbacks, to: 'paypal_callbacks#show'
      get :dashboard, to: 'dashboard#show'
    end

    resources :sellers do
      member do
        get :start_onboarding_process
      end
    end
  end
end
