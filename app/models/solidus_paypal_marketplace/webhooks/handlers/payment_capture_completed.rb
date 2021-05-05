# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Webhooks
    module Handlers
      class PaymentCaptureCompleted < Base
        def call
          payment_source = payment.payment_source
          if payment_source.update(response_status: :completed)
            payment.complete! unless payment.completed?
            update_shipment_state
            { result: true }
          else
            { result: false, errors: payment_source.errors.full_messages }
          end
        end

        private

        def payment
          Spree::Payment.find(resource["id"])
        end

        def update_shipment_state
          payment.order.shipments.each do |shipment|
            SolidusPaypalMarketplace::Sellers::ShipmentManagement::Ready.call(shipment)
          end
        end
      end
    end
  end
end
