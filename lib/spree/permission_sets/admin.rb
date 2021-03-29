# frozen_string_literal: true

module Spree
  module PermissionSets
    class Admin < PermissionSets::Base
      def activate!
        cannot :visit, :seller_dashboard unless user&.has_spree_role?('seller')
        cannot :visit, :seller_prices unless user&.has_spree_role?('seller')
        cannot :visit, :seller_shipments unless user&.has_spree_role?('seller')
        cannot :visit, :paypal_callbacks unless user&.has_spree_role?('seller')
      end
    end
  end
end
