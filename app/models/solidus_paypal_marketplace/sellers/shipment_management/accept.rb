# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Sellers
    module ShipmentManagement
      class Accept < Base
        def call(shipment)
          return false unless shipment.order.payments.all?(&:can_complete?)

          shipment.order.payments.each(&:capture!)
          SolidusPaypalMarketplace::Sellers::ShipmentManagement::Ready.call(shipment)
        end
      end
    end
  end
end
