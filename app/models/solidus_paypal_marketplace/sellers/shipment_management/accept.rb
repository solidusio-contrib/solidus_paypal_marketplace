# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Sellers
    module ShipmentManagement
      class Accept < Base
        def call(shipment)
          return false unless shipment.order.payments.all?(&:can_complete?)

          result = true
          ActiveRecord::Base.transaction do
            shipment.order.payments.each(&:capture!)
            if shipment.can_ready?
              shipment.ready!
            else
              result = false
              raise ActiveRecord::Rollback
            end
          end
          result
        end
      end
    end
  end
end
