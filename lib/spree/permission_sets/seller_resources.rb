# frozen_string_literal: true

module Spree
  module PermissionSets
    class SellerResources < PermissionSets::Base
      def activate!
        # NB: leaving this guard since seller presence is not validated yet for users with `seller` role
        return unless user.seller_id && user.seller.accepted?

        can :manage, Spree::LineItem, seller_id: user.seller_id, order: { state: 'complete' }
        can :manage, Spree::Price, seller_id: user.seller_id
        can :manage, Spree::Shipment, stock_location: { seller_id: user.seller_id }
        cannot :manage, Spree::Shipment, order: { completed_at: nil }
      end
    end
  end
end
