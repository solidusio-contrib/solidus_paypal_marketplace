# frozen_string_literal: true

module Spree
  module PermissionSets
    class Seller < PermissionSets::Base
      def activate!
        can :visit, :seller_dashboard
        can :visit, :seller_prices if user.seller&.accepted?
        can :visit, :paypal_callbacks
      end
    end
  end
end
