# frozen_string_literal: true

module SolidusPaypalMarketplace
  class HTTPClient
    attr_reader :client

    PARTNER_ATTRIBUTION_INJECTOR = ->(request) {
      request.headers["PayPal-Partner-Attribution-Id"] = SolidusPaypalMarketplace.configuration.partner_code
    }.freeze

    def initialize
      client_id = SolidusPaypalMarketplace.configuration.paypal_client_id
      client_secret = SolidusPaypalMarketplace.configuration.paypal_client_secret
      environment = PayPal::SandboxEnvironment.new(client_id, client_secret)
      @client = PayPal::PayPalHttpClient.new(environment)
      @client.add_injector(&PARTNER_ATTRIBUTION_INJECTOR)
    end
  end
end
