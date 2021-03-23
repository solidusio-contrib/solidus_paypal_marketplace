# frozen_string_literal: true

module SolidusPaypalMarketplace
  module PaypalPartnerSdk
    class CreatePartnerReferral
      attr_accessor :path, :body, :headers, :verb

      DEFAULT_BODY = {
        "operations": [
          {
            "operation": "API_INTEGRATION",
            "api_integration_preference": {
              "rest_api_integration": {
                "integration_method": "PAYPAL",
                "integration_type": "THIRD_PARTY",
                "third_party_details": {
                  "features": [
                    "PAYMENT",
                    "REFUND",
                    "PARTNER_FEE"
                  ]
                }
              }
            }
          }
        ],
        "products": [
          "EXPRESS_CHECKOUT"
        ],
        "legal_consents": [
          {
            "type": "SHARE_DATA_CONSENT",
            "granted": true
          }
        ]
      }.freeze

      def initialize(tracking_id: nil, return_url: nil)
        @headers = {}
        @verb = "POST"
        @path = "/v2/customer/partner-referrals?"
        @headers["Content-Type"] = "application/json"

        params = {}
        params = { "tracking_id": tracking_id } if tracking_id.present?
        params[:partner_config_override] = { 'return_url': return_url } if return_url.present?

        @body = request_body(params)
      end

      def request_body(params)
        self.class::DEFAULT_BODY.merge params
      end
    end
  end
end
