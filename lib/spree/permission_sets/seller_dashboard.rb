# frozen_string_literal: true

module Spree
  module PermissionSets
    class SellerDashboard < PermissionSets::Base
      def activate!
        cannot :visit, :seller_dashboard if !user&.has_spree_role?('seller')
        cannot :visit, :seller_prices if !user&.has_spree_role?('seller')

        can :visit, :seller_dashboard if user.has_spree_role?('seller')
        can :visit, :seller_prices if user.has_spree_role?('seller') && user.seller&.accepted?
      end
    end
  end
end
