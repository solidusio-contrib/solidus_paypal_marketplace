# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ReturnLowestSellerPriceInProductPriceForDecorator, type: :model do
  let(:described_class) { Spree::Product }
  let(:product) { variant.product }
  let(:variant) { create(:variant) }
  let(:pricing_options) { Spree::Config.pricing_options_class.new }

  it do
    expect(described_class.new).to respond_to(:price_for)
  end

  it do
    expect(described_class.new).to respond_to(:price_for_master)
  end

  it do
    expect(described_class.new).to respond_to(:prices_for_variants)
  end

  describe '#price_for' do
    subject(:price_for) { product.price_for(pricing_options) }

    let(:price_selector) { instance_double(Spree::Variant::SellersPriceSelector, lowest_seller_price_for: nil) }

    context 'when product does not have variant seller prices' do
      let(:master_variant) { variant.product.master }
      let(:master_price_selector) {
        instance_double(Spree::Variant::SellersPriceSelector, lowest_seller_price_for: '$20')
      }

      it 'calls variants#lowest_sellers_price_for' do
        allow(variant).to receive(:price_selector).and_return(price_selector)
        price_for
        expect(price_selector).to have_received(:lowest_seller_price_for)
      end

      it 'calls master#lowest_sellers_price_for' do
        allow(master_variant).to receive(:price_selector).and_return(master_price_selector)
        price_for
        expect(master_price_selector).to have_received(:lowest_seller_price_for)
      end

      it 'returns master#lowest_sellers_price_for' do
        allow(master_variant).to receive(:price_selector).and_return(master_price_selector)
        expect(price_for).to eq '$20'
      end
    end

    context 'when product has variant seller prices' do
      let(:other_variant) { create(:variant, product: variant.product) }

      it 'calls variants#lowest_sellers_price_for' do
        allow(variant).to receive(:price_selector).and_return(price_selector)
        price_for
        expect(price_selector).to have_received(:lowest_seller_price_for)
      end

      it 'returns sellers lowest price for any variant' do
        sellers = [create(:seller, name: 'One'), create(:seller, name: 'Two')]
        create(:price, variant: variant, amount: 30.00, seller: sellers.second)
        create(:price, variant: other_variant, amount: 50.00, seller: sellers.first)
        expect(price_for).to eq Spree::Money.new(30.00, currency: 'USD')
      end
    end
  end
end
