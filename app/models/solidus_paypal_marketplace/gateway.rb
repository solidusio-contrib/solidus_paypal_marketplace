# frozen_string_literal: true

module SolidusPaypalMarketplace
  class Gateway < SolidusPaypalCommercePlatform::Gateway
    def initialize(options) # rubocop:disable Lint/MissingSuper
      # Cannot use kwargs because of how the Gateway is initialize by Solidus.
      @client = Client.new(
        test_mode: options.fetch(:test_mode, nil),
        client_id: options.fetch(:client_id),
        client_secret: options.fetch(:client_secret),
        partner_code: options.fetch(:partner_code)
      )
      @options = options
    end
  end
end
