# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AddItemFromSameSellerCheckOnOrderDecorator, type: :model do
  let(:described_class) { Spree::Order }

  describe '#item_from_same_seller' do
    subject(:item_from_same_seller) { line_item.order.item_from_same_seller(line_item, options) }

    let(:line_item) { build_stubbed(:line_item, seller: build_stubbed(:seller)) }

    context 'when seller is nil' do
      let(:options) { { options: { seller_id: nil } } }

      it 'raises OptionSellerIdRequired' do
        expect { item_from_same_seller }.to raise_exception Spree::Order::OptionSellerIdRequired
      end
    end

    context 'when argument seller is equal to line item seller' do
      let(:options) { { options: { seller_id: line_item.seller_id } } }

      it 'return true' do
        expect(item_from_same_seller).to be true
      end
    end

    context 'when argument seller is not equal to line item seller' do
      let(:options) { { options: { seller_id: 0 } } }

      it 'return true' do
        expect(item_from_same_seller).to be false
      end
    end
  end
end
