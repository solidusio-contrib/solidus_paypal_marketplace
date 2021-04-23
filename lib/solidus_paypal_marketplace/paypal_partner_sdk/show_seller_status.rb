# frozen_string_literal: true

module SolidusPaypalMarketplace
  module PaypalPartnerSdk
    class ShowSellerStatus
      attr_accessor :path, :verb, :headers, :body

      def initialize(merchant_id:)
        partner_id = SolidusPaypalMarketplace.configuration.paypal_partner_id
        @verb = "GET"
        @path = "/v1/customer/partners/#{partner_id}/merchant-integrations/#{merchant_id}"
      end
    end
  end
end
