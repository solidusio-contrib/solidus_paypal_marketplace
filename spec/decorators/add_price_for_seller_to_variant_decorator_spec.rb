# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AddPriceForSellerToVariantDecorator, type: :model do
  let(:described_class) { Spree::Variant }

  it do
    expect(described_class.new).to delegate_method(:price_for_seller).to :price_selector
  end

  describe '.with_prices' do
    let(:variant) { create(:variant) }

    it 'returns sellers prices' do
      create(:price, variant: variant)
      expect(Spree::Variant.with_prices).not_to include(variant)
    end

    it 'does not return platform owner prices' do
      create(:price, variant: variant, seller: create(:seller))
      expect(Spree::Variant.with_prices).to include(variant)
    end
  end
end
