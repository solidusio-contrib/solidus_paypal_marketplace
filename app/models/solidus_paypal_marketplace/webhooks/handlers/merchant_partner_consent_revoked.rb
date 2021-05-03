# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Webhooks
    module Handlers
      class MerchantPartnerConsentRevoked < Base
        def call
          if seller.update(status: :revoked)
            { result: true }
          else
            { result: false, errors: seller.errors.full_messages }
          end
        end

        private

        def seller
          Spree::Seller.find_by!(merchant_id_in_paypal: resource["merchant_id"])
        end
      end
    end
  end
end
