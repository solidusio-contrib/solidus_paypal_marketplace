# frozen_string_literal: true

module AddPaypalChecksToPaymentDecorator
  def paypal_pending?
    return false unless source.is_a?(SolidusPaypalCommercePlatform::PaymentSource)

    source.pending?
  end

  Spree::Payment.prepend self
end
