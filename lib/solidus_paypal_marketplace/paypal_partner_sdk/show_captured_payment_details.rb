# frozen_string_literal: true

module SolidusPaypalMarketplace
  module PaypalPartnerSdk
    class ShowCapturedPaymentDetails
      attr_accessor :path, :verb, :headers, :body

      def initialize(capture_id:)
        @verb = "GET"
        @path = "/v2/payments/captures/#{capture_id}"
      end
    end
  end
end
