# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Sellers
    module ShipmentManagement
      class Cancel < Base
        def call(shipment)
          return false unless shipment.can_cancel?

          shipment.cancel!
        end
      end
    end
  end
end
