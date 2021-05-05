# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Sellers
    module ShipmentManagement
      class Reject < Base
        def call(shipment)
          return false unless shipment.order.payments.all?(&:can_void?) && shipment.can_cancel?

          ActiveRecord::Base.transaction do
            shipment.order.payments.each(&:void_transaction!)
            shipment.cancel!
          end
        end
      end
    end
  end
end
