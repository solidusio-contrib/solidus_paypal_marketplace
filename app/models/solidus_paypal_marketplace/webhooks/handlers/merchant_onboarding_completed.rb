# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Webhooks
    module Handlers
      class MerchantOnboardingCompleted < Base
        def call
          refreshed_seller = SolidusPaypalMarketplace::Sellers::StatusRefresh.call(
            seller,
            return_url: @context.admin_sellers_paypal_callbacks_url
          ).seller
          if refreshed_seller.save
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
          resource["merchant_id"]
        end

        def seller
          Spree::Seller.find_by!(merchant_id_in_paypal: merchant_id)
        end
      end
    end
  end
end
