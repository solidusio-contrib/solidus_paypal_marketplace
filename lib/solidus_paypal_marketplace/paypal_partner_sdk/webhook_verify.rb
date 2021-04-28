# frozen_string_literal: true

module SolidusPaypalMarketplace
  module PaypalPartnerSdk
    class WebhookVerify
      PATH = '/v1/notifications/verify-webhook-signature'
      VERB = 'POST'
      HEADERS = { "Content-Type": "application/json" }.freeze

      attr_accessor :path, :verb, :headers, :body

      def initialize(headers:, params:)
        @path = PATH.dup
        @verb = VERB.dup
        @headers = { "Content-Type" => "application/json" }
        @body = {
          "auth_algo" => headers["PAYPAL-AUTH-ALGO"],
          "cert_url" => headers["PAYPAL-CERT-URL"],
          "transmission_id" => headers["PAYPAL-TRANSMISSION-ID"],
          "transmission_sig" => headers["PAYPAL-TRANSMISSION-SIG"],
          "transmission_time" => headers["PAYPAL-TRANSMISSION-TIME"],
          "webhook_id" => SolidusPaypalMarketplace.config.paypal_webhook_id,
          "webhook_event" => params
        }
      end
    end
  end
end
