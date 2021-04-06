# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::CreatePaypalOrderPayload, type: :model do
  describe '#to_json' do
    subject(:to_json) { described_class.new(order).to_json(intent) }

    let(:intent) { 'AUTHORIZE' }
    let(:seller) { create(:seller) }
    let(:price) { create(:price, seller: seller) }
    let(:line_item_attributes) { { variant: price.variant, seller: price.seller } }
    let(:order) { create(:order_ready_to_complete, line_items_attributes: [line_item_attributes]) }

    it 'adds the merchant id to the payee' do
      expect(to_json).to match hash_including(
        purchase_units: array_including(hash_including(payee: { merchant_id: seller.merchant_id_in_paypal }))
      )
    end

    it "doesn't add the payment_instruction to the payload" do
      expect(to_json).not_to match hash_including(
        purchase_units: array_including(hash_including(
          :payment_instruction
        ))
      )
    end

    context 'when the intent is capture' do
      let(:intent) { 'CAPTURE' }

      it 'add the payment_instruction to the payload' do
        expect(to_json).to match hash_including(
          purchase_units: array_including(hash_including(
            payment_instruction: hash_including(
              platform_fees: array_including(hash_including(
                amount: {
                  currency_code: order.currency,
                  value: (order.total * (seller.percentage / 100.0)).round(2)
                }
              ))
            )
          ))
        )
      end
    end
  end
end
