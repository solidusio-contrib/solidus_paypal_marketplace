# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Sellers
    module ShipmentManagement
      class Reject < Base
        def call(shipment, merchant_id_in_paypal: nil)
          payments = shipment.order.payments.map do |payment|
            payment.request_env = { merchant_id_in_paypal: merchant_id_in_paypal }
            payment
          end
          return false unless payments.all?(&:can_void?) && shipment.can_cancel?

          ActiveRecord::Base.transaction do
            payments.each(&:void_transaction!)
            shipment.cancel!
          end
        end
      end
    end
  end
end
