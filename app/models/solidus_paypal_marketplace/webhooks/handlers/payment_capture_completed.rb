# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Webhooks
    module Handlers
      class PaymentCaptureCompleted < Base
        def call
          payment_source = payment.payment_source
          if payment_source.update(response_status: :completed)
            { result: true }
          else
            { result: false, errors: payment_source.errors.full_messages }
          end
        end

        private

        def payment
          Spree::Payment.find(resource["id"])
        end
      end
    end
  end
end
