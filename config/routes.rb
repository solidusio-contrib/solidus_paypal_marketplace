# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :sellers
  end
end
