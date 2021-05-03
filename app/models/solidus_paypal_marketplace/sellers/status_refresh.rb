# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Sellers
    class StatusRefresh
      INTEGRATION_TYPE = "OAUTH_THIRD_PARTY"
      INTEGRATION_METHOD = "PAYPAL"
      OAUTH_THIRD_PARTY_SCOPES = [
        "https://uri.paypal.com/services/payments/realtimepayment",
        "https://uri.paypal.com/services/payments/partnerfee",
        "https://uri.paypal.com/services/payments/refund",
        "https://uri.paypal.com/services/payments/payment/authcapture"
      ].freeze

      attr_reader(
        :seller,
        :unconfirmed_primary_email,
        :wrong_oauth_third_party_permissions
      )

      def self.call(*args)
        new(*args).call
      end

      def initialize(seller, return_url: nil)
        @seller = seller
        @return_url = return_url
        @unconfirmed_primary_email = false
        @wrong_oauth_third_party_permissions = false
      end

      def call
        if oauth_integration_valid? != true
          @seller.status = :pending
          @seller.start_onboarding_process(return_url: @return_url)
          @wrong_oauth_third_party_permissions = true
        elsif seller_status.primary_email_confirmed != true
          @seller.status = :waiting_paypal_confirmation
          @unconfirmed_primary_email = true
        elsif seller_status.payments_receivable != true
          @seller.status = :require_paypal_verification
        else
          @seller.status = :accepted
        end
        @seller.save
        self
      end

      private

      def seller_status
        @seller_status ||= SolidusPaypalMarketplace::PaypalPartnerSdk.show_seller_status(
          merchant_id: @seller.merchant_id_in_paypal
        )
        @seller_status
      end

      def oauth_integration
        @oauth_integration ||= seller_status.oauth_integrations&.detect do |integration|
          integration.integration_type == INTEGRATION_TYPE && \
          integration.integration_method == INTEGRATION_METHOD
        end
      end

      def oauth_third_party
        @oauth_third_party ||= oauth_integration.oauth_third_party.detect do |third_party|
          third_party.partner_client_id == SolidusPaypalMarketplace.config.paypal_client_id
        end
      end

      def oauth_integration_valid?
        oauth_integration.present? && \
        oauth_third_party.present? && \
        oauth_third_party.scopes.present? && \
        # TODO: verify
        OAUTH_THIRD_PARTY_SCOPES.all? do |scope|
          oauth_third_party.scopes.include?(scope)
        end
      end
    end
  end
end
