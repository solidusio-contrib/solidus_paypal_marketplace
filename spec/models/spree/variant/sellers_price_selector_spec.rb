# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Variant::SellersPriceSelector, type: :model do
  subject(:seller_price_selector) { described_class.new(variant) }

  let(:country) { create(:country) }
  let(:price) {
    Spree::Price.find_or_create_by!(amount: 15,
                                    country: country,
                                    currency: pricing_options.currency,
                                    seller: seller,
                                    variant: variant)
  }
  let(:pricing_options) { described_class.pricing_options_class.new(currency: 'USD', country_iso: country.iso) }
  let(:seller) { nil }
  let(:variant) { create(:variant) }

  it do
    expect(seller_price_selector).to respond_to(:price_for).with(1).arguments
  end

  it do
    expect(seller_price_selector).to respond_to(:price_for_seller).with(2).arguments
  end

  describe '#price_for' do
    before do
      price.save!
    end

    it do
      expect(seller_price_selector.price_for(pricing_options)).to be_kind_of(Spree::Money)
    end

    it 'selects price for variant and pricing options' do
      expect(seller_price_selector.price_for(pricing_options)).to eq(price.money)
    end
  end

  describe '#price_for_seller' do
    let(:seller) { create(:seller) }

    before do
      price.save!
    end

    it do
      expect(seller_price_selector.price_for_seller(seller, pricing_options)).to be_kind_of(Spree::Money)
    end

    it 'selects seller price for variant and pricing options' do
      expect(seller_price_selector.price_for_seller(seller, pricing_options)).to eq(price.money)
    end
  end
end
