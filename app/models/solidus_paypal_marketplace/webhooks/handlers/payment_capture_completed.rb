# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Webhooks
    module Handlers
      class PaymentCaptureCompleted < Base
        def call
          if payment_source.update(response_status: :completed)
            payment_source.payments.each do |payment|
              if payment.completed? != true
                payment.started_processing!
                payment.complete!
              end
            end
            { result: true }
          else
            { result: false, errors: payment_source.errors.full_messages }
          end
        end

        private

        def payment_source
          SolidusPaypalCommercePlatform::PaymentSource.find_by!(capture_id: resource["id"])
        end
      end
    end
  end
end
