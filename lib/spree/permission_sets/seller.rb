module Spree
  module PermissionSets
    class Seller < PermissionSets::Base
      def activate!
        can :manage, Spree::Order
        can :manage, Spree::Price, seller_id: user.id
      end
    end
  end
end
