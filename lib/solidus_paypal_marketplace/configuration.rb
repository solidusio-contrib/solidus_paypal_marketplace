# frozen_string_literal: true

module SolidusPaypalMarketplace
  class Configuration
    attr_accessor :paypal_client_id, :paypal_client_secret, :partner_code
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    alias config configuration

    def configure
      yield configuration
    end
  end
end
