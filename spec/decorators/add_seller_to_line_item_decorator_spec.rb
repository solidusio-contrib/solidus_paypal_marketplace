# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AddSellerToLineItemDecorator, type: :model do
  let(:described_class) { Spree::LineItem }

  it do
    expect(described_class.new)
      .to belong_to(:seller)
      .class_name('Spree::Seller')
  end

  it do
    expect(described_class.new.pricing_options).to be_kind_of(Spree::Variant::SellersPricingOptions)
  end

  describe '#validate_seller_price_presence' do
    subject(:valid?) { line_item.valid? }

    let(:seller) { create(:seller) }
    let(:price) { create(:price, seller: seller) }
    let(:line_item) { build(:line_item, variant: price.variant, seller: seller) }

    it 'is valid' do
      expect(valid?).to be_truthy
    end

    context 'when there are no prices for variant' do
      let(:variant) { create(:variant).tap { |v| v.prices.delete_all } }
      let(:line_item) { build(:line_item, variant: variant, seller: seller) }

      it 'is not valid' do
        expect(line_item.variant.prices).to be_empty

        expect(valid?).to be_falsey

        expect(
          line_item.errors.added?(:seller, :no_prices)
        ).to be true
      end
    end

    context 'when there are no prices for seller/variant combination' do
      let(:price) { create(:price, seller: create(:seller, name: 'Other Seller')) }

      it 'is not valid' do
        expect(line_item.variant.prices.where(seller: seller)).to be_empty

        expect(valid?).to be_falsey

        expect(
          line_item.errors.added?(:seller, :no_prices)
        ).to be true
      end
    end
  end

  describe '#sufficient_stock?' do
    subject { line_item.sufficient_stock? }

    let(:line_item) { build_stubbed(:line_item, quantity: 10) }

    before do
      create(:stock_location, propagate_all_variants: true, backorderable_default: false)

      line_item

      Spree::StockItem.update_all(count_on_hand: 10) # rubocop:disable Rails/SkipsModelValidations
    end

    it { is_expected.to be_falsey }

    context 'when the seller is related to the right stock location' do
      let(:seller) { create(:seller) }
      let!(:stock_location1) do
        create(
          :stock_location,
          propagate_all_variants: true,
          backorderable_default: false,
          seller: seller
        )
      end
      let(:line_item) { build_stubbed(:line_item, quantity: 10, seller: stock_location1.seller) }

      it { is_expected.to be_truthy }

      context 'when there are no sufficient stock in the stock location related to the selected seller' do
        before do
          Spree::StockItem.find_by(stock_location: stock_location1).set_count_on_hand(9)
        end

        it { is_expected.to be_falsey }
      end
    end
  end
end
