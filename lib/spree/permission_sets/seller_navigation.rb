# frozen_string_literal: true

module Spree
  module PermissionSets
    class SellerNavigation < PermissionSets::Base
      def activate!
        can :visit, :paypal_callbacks
        can :visit, :seller_dashboard
        can :visit, :seller_prices if user.seller.accepted?
        can :visit, :seller_shipments if user.seller.accepted?
      end
    end
  end
end
