# frozen_string_literal: true

require 'paypal-checkout-sdk'

module SolidusPaypalMarketplace
  class HTTPClient < PayPal::PayPalHttpClient
    PARTNER_ATTRIBUTION_INJECTOR = ->(request) {
      request.headers["PayPal-Partner-Attribution-Id"] = SolidusPaypalMarketplace.configuration.partner_code
    }.freeze

    def initialize
      super(SolidusPaypalMarketplace.config.paypal_environment)
      add_injector(&PARTNER_ATTRIBUTION_INJECTOR)
    end
  end
end
