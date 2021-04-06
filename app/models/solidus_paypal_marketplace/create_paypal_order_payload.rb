# frozen_string_literal: true

module SolidusPaypalMarketplace
  class CreatePaypalOrderPayload < SolidusPaypalCommercePlatform::PaypalOrder
    attr_reader :intent

    def to_json(intent)
      @intent = intent

      {
        intent: intent,
        purchase_units: purchase_units,
        payer: (payer if @order.bill_address)
      }
    end

    private

    def purchase_units(include_shipping_address: true)
      payload = {
        amount: amount,
        items: line_items,
        shipping: (shipping_info if @order.ship_address && include_shipping_address),
        payee: {
          merchant_id: seller.merchant_id_in_paypal
        }
      }

      payload[:payment_instruction] = payment_instruction if intent == 'CAPTURE'

      [payload]
    end

    def payment_instruction
      {
        disbursement_mode: 'INSTANT',
        platform_fees: [{
          amount: {
            currency_code: @order.currency,
            value: platform_fee
          }
        }]
      }
    end

    def platform_fee
      (@order.total * (seller.percentage / 100.0)).round(2)
    end

    def seller
      @seller ||= @order.line_items.first.seller
    end
  end
end
