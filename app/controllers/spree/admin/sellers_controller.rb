
module Spree
  module Admin
    class SellersController < Spree::Admin::ResourceController
      before_action :set_merchant_id,
                    :set_action_url, only: [:create]

      private

      def set_action_url
        @seller.action_url = 'url'
      end

      def set_merchant_id
        @seller.merchant_id = SecureRandom.uuid
      end
    end
  end
end