# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusPaypalMarketplace
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_paypal_marketplace'

    initializer "solidus_paypal_marketplace.add_static_preference", after: "spree.register.payment_methods" do |app|
      Spree::Config.static_model_preferences.add(
        SolidusPaypalMarketplace::PaymentMethod,
        'paypal_marketplace_credentials', {
          test_mode: !Rails.env.production?,
          client_id: SolidusPaypalMarketplace.configuration.paypal_client_id,
          client_secret: SolidusPaypalMarketplace.configuration.paypal_client_secret,
          partner_code: SolidusPaypalMarketplace.configuration.partner_code
        }
      )

      app.config.spree.payment_methods << SolidusPaypalMarketplace::PaymentMethod
    end

    config.generators do |g|
      g.test_framework :rspec
    end

    config.before_initialize do
      Dir.glob(File.join(File.dirname(__FILE__), "../spree/permission_sets/*.rb")) do |c|
        require_dependency(c)
      end
    end
  end
end
