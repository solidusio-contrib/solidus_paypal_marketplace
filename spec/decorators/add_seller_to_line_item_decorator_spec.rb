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
end
