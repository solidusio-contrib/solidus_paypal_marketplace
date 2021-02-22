
module Spree
  module Admin
    class SellersController < Spree::Admin::ResourceController
      before_action :set_merchant_id,
                    :set_action_url, only: [:create]

      private

      def set_action_url
        @seller.action_url = ''
      end

      def set_merchant_id
        @seller.merchant_id = Digest::UUID.uuid_v5(
          Digest::UUID::DNS_NAMESPACE,
          request.host
        )
      end
    end
  end
end