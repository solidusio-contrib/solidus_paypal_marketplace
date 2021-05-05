# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Sellers
    module ShipmentManagement
      class Ready < Base
        def call(shipment)
          return false unless shipment.order.payments.map(&:completed?) && shipment.can_ready?

          shipment.ready!
        end
      end
    end
  end
end
