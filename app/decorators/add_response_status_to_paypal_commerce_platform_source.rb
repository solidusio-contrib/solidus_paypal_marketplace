# frozen_string_literal: true

module AddResponseStatusToPaypalCommercePlatformSource
  def self.prepended(base)
    base.enum response_status: {
      completed: 0,
      declined: 1,
      partially_refunded: 2,
      pending: 3,
      refunded: 4
    }
  end

  SolidusPaypalCommercePlatform::PaymentSource.prepend self
end
