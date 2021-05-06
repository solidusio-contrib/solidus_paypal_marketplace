# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Variant::SellersPriceSelector, type: :model do
  subject(:seller_price_selector) { described_class.new(variant) }

  let!(:price) {
    Spree::Price.find_or_create_by!(amount: 15,
                                    country: country,
                                    currency: pricing_options.currency,
                                    seller: seller,
                                    variant: variant)
  }
  let(:country) { create(:country) }
  let(:pricing_options) { described_class.pricing_options_class.new(currency: 'USD', country_iso: country.iso) }
  let(:seller) { create(:seller) }
  let(:variant) { create(:variant) }

  it do
    expect(seller_price_selector).to respond_to(:price_for).with(1).arguments
  end

  it do
    expect(seller_price_selector).to respond_to(:price_for_seller).with(2).arguments
  end

  describe '#lowest_seller_price_for' do
    subject(:lowest_seller_price_for) { variant.lowest_seller_price_for(pricing_options) }

    let(:other_seller) { create(:seller, name: 'Two') }
    let(:other_price) { create(:price, variant: variant, amount: price.amount + 5.00, seller: other_seller) }

    it 'returns lowest seller price' do
      other_price

      if ::Spree.solidus_gem_version >= Gem::Version.new('3.1.0.alpha')
        expect(lowest_seller_price_for).to eq price
      else
        expect(lowest_seller_price_for).to eq Spree::Money.new(price.amount, currency: 'USD')
      end
    end

    context 'when there are no sellers prices' do
      it 'returns nil' do
        price.update!(seller: nil)
        expect(lowest_seller_price_for).to be_nil
      end
    end
  end

  describe '.pricing_options_class' do
    it do
      expect(described_class.pricing_options_class).to be(Spree::Variant::SellersPricingOptions)
    end
  end

  describe '#price_for' do
    subject(:price_for) { seller_price_selector.price_for(pricing_options) }

    if ::Spree.solidus_gem_version >= Gem::Version.new('3.1.0.alpha')
      it do
        expect(price_for).to be_kind_of(Spree::Price)
      end

      it 'selects price for variant and pricing options' do
        expect(price_for).to eq(price)
      end

      it 'returns last price created by seller' do
        new_price = Spree::Price.create!(amount: 20,
                                         country: country,
                                         currency: pricing_options.currency,
                                         seller: seller,
                                         variant: variant)
        expect(price_for).to eq(new_price)
      end
    else
      it do
        expect(price_for).to be_kind_of(Spree::Money)
      end

      it 'selects price(money) for variant and pricing options' do
        expect(price_for).to eq(price.money)
      end

      it 'returns last price(money) created by seller' do
        new_price = Spree::Price.create!(amount: 20,
                                         country: country,
                                         currency: pricing_options.currency,
                                         seller: seller,
                                         variant: variant)
        expect(price_for).to eq(new_price.money)
      end
    end

    it 'does not return platform owner prices' do
      price.update!(seller: nil)
      expect(price_for).to be_nil
    end
  end

  describe '#price_for_seller' do
    subject(:price_for_seller) { seller_price_selector.price_for_seller(seller, pricing_options) }

    if ::Spree.solidus_gem_version >= Gem::Version.new('3.1.0.alpha')
      it do
        expect(price_for_seller).to be_kind_of(Spree::Price)
      end

      it 'selects seller price for variant and pricing options' do
        expect(price_for_seller).to eq(price)
      end
    else
      it do
        expect(price_for_seller).to be_kind_of(Spree::Money)
      end

      it 'selects seller price(money) for variant and pricing options' do
        expect(price_for_seller).to eq(price.money)
      end
    end
  end
end
