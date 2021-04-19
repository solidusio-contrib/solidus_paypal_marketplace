# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Webhooks
    module Handlers
      class MerchantPartnerConsentRevoked < Base
        def call
          seller.update!(status: :revoked)
        end
      end
    end
  end
end
