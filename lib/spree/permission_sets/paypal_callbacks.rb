# frozen_string_literal: true

module Spree
  module PermissionSets
    class PaypalCallbacks < PermissionSets::Base
      def activate!
        cannot :manage, :paypal_callbacks if !user&.has_spree_role?('seller')
        can :manage, :paypal_callbacks if user.has_spree_role?('seller')
      end
    end
  end
end
