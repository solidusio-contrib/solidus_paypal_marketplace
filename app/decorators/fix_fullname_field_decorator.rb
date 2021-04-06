# frozen_string_literal: true

module FixFullnameFieldDecorator
  private

  def shipping_info
    {
      name: {
        full_name: @order.ship_address.name
      },
      email_address: @order.email,
      address: get_address(@order.ship_address)
    }
  end

  def name(address)
    {
      given_name: address.name
    }
  end

  SolidusPaypalCommercePlatform::PaypalOrder.prepend self
end
