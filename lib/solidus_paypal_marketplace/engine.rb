# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

module SolidusPaypalMarketplace
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace ::Spree

    engine_name 'solidus_paypal_marketplace'

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
