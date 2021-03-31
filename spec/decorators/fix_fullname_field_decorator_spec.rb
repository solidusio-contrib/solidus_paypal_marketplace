# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FixFullnameFieldDecorator, type: :model do
  let(:described_class) { SolidusPaypalCommercePlatform::PaypalOrder }

  describe '#to_json' do
    subject(:to_json) { described_class.new(order).to_json('intent') }

    let(:seller) { create(:seller) }
    let(:price) { create(:price, seller: seller) }
    let(:line_item_attributes) { { variant: price.variant, seller: price.seller } }
    let(:order) { create(:order_ready_to_complete, line_items_attributes: [line_item_attributes]) }

    it { expect { to_json }.not_to raise_error }

    it 'returns the name of the user' do
      expect(to_json).to match hash_including(
        purchase_units: array_including(hash_including(shipping: hash_including(name: { full_name: 'John Von Doe' }))),
        payer: hash_including(name: { given_name: 'John Von Doe' })
      )
    end
  end
end
