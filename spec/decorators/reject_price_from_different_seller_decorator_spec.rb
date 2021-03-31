# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RejectPriceFromDifferentSellerDecorator, type: :model do
  let(:described_class) { Spree::LineItem }

  describe '#reject_price_from_different_seller' do
    subject { line_item }

    let(:seller) { create(:seller) }
    let(:price) { create(:price, seller: seller) }
    let(:line_item) { build(:line_item, variant: price.variant, seller: seller) }

    it { is_expected.to be_valid }

    context 'when the order contains another line item from the same seller' do
      let(:already_present_line_item) { create(:line_item, variant: price.variant, seller: seller) }

      it { is_expected.to be_valid }
    end

    context 'when the order contains another line item from a different seller' do
      let(:other_seller) { create(:seller, name: 'Other Seller') }
      let(:other_price) { create(:price, seller: other_seller) }
      let(:already_present_line_item) do
        create(:line_item, variant: other_price.variant, order: line_item.order, seller: other_seller)
      end

      before { already_present_line_item }

      it 'cannot add a variant from another seller' do
        expect(line_item).not_to be_valid

        expect(line_item.errors.added?(:seller, :cannot_add_line_item_from_different_seller)).to be true
      end
    end
  end
end
