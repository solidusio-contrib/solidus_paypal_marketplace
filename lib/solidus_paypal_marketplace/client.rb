# frozen_string_literal: true

require 'solidus_paypal_commerce_platform/access_token_authorization_request'
require 'solidus_paypal_commerce_platform/fetch_merchant_credentials_request'
require 'solidus_paypal_commerce_platform/client'

require 'paypal-checkout-sdk'

module SolidusPaypalMarketplace
  class Client < SolidusPaypalCommercePlatform::Client
    def initialize(client_id:, client_secret: "", test_mode: nil, partner_code: '') # rubocop:disable Lint/MissingSuper
      test_mode = SolidusPaypalCommercePlatform.config.env.sandbox? if test_mode.nil?
      env_class = test_mode ? PayPal::SandboxEnvironment : PayPal::LiveEnvironment

      @environment = env_class.new(client_id, client_secret)
      @paypal_client = PayPal::PayPalHttpClient.new(@environment)
      @partner_code = partner_code

      @paypal_client.add_injector(&method(:partner_code))
    end

    private

    def partner_code(request)
      request.headers["PayPal-Partner-Attribution-Id"] = @partner_code
    end
  end
end
