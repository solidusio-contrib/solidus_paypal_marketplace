# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  namespace :admin do
    namespace :sellers do
      resources :prices, path: :offers
    end
    resources :sellers
  end
end
