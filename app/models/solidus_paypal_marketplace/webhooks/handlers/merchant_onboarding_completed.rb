# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Webhooks
    module Handlers
      class MerchantOnboardingCompleted < Base
        def call
          status = seller_status["payments_receivable"] ? :accepted : :require_paypal_verification
          if seller.update(status: status)
            { result: true }
          else
            { result: false, errors: seller.errors.full_messages }
          end
        end

        private

        def seller_status
          SolidusPaypalMarketplace::PaypalPartnerSdk.show_seller_status(
            merchant_id: merchant_id
          )
        end

        def merchant_id
          params["merchant_id"]
        end

        def seller
          Spree::Seller.find_by(merchant_id_in_paypal: merchant_id)
        end
      end
    end
  end
end
