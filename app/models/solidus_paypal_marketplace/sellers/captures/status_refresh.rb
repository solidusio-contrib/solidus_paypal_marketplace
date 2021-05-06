# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Sellers
    module Captures
      class StatusRefresh
        def self.call(*args)
          new.call(*args)
        end

        def call(capture_id)
          payment_source = SolidusPaypalCommercePlatform::PaymentSource.find_by!(capture_id: capture_id)
          capture_status = SolidusPaypalMarketplace::PaypalPartnerSdk.show_captured_payment_details(
            capture_id: capture_id
          )
          status = capture_status.status.downcase
          payment_source.update!(response_status: status)
          payment_source.payments.each do |payment|
            payment.started_processing!
            payment.complete! if status == 'completed' && payment.completed? != true
            payment.failure! if status == 'declined' && payment.failed? != true
          end
          true
        end
      end
    end
  end
end
