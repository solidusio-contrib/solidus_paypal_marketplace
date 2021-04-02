# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Sellers
    module ShipmentManagement
      class Ship < Base
        def call(shipment)
          return false unless shipment.can_ship?

          shipment.ship!
        end
      end
    end
  end
end
