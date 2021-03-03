# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :sellers
    scope module: :sellers do
      resources :prices
    end
  end
end
