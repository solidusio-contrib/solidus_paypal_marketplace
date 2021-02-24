# frozen_string_literal: true

namespace :solidus_paypal_marketplace do
  namespace :db do
    desc 'Load solidus paypal marketplace seeds'
    task seed: :environment do
      SolidusPaypalMarketplace::Engine.load_seed if defined?(SolidusPaypalMarketplace)
    end
  end
end
