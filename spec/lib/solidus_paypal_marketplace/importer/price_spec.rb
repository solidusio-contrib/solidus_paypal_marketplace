# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Importer::Price do
  subject(:price_importer) do
    described_class.new(currency: currency, file: file, originator: seller, prices_scope: prices_scope)
  end

  let(:currency) { 'USD' }
  let(:file) do
    file = Tempfile.new(['offers', '.csv'])
    file.write(file_content)
    file.rewind
    file
  end
  let(:file_content) { "Sku,Price,Stock availability\n#{variant.sku},1.0,100\n" }
  let(:prices_scope) { Spree::Price.where(seller_id: seller) }
  let(:seller) { create(:seller) }
  let(:variant) { create(:variant, sku: 'AAA-000') }

  describe 'inizialization' do
    it 'sets prices' do
      prices = price_importer.prices
      expect(prices).to be_present
      expect(prices.size).to be(1)
    end

    context 'when csv format is not compliant' do
      let(:file_content) { "SKU,Price,Stock availability\n#{variant.sku},1.0,0\n" }

      it 'raises exception' do
        expect{ price_importer }.to raise_exception(StandardError, 'uncompliant csv format')
      end
    end

    context 'when a row of values is incomplete' do
      let(:file_content) { "Sku,Price,Stock availability\n#{variant.sku}, ,0\n" }

      it 'adds an error' do
        expect(price_importer.errors).to include('AAA-000: row values must all be filled')
      end
    end
  end

  describe 'call' do
    before do
      variant
    end

    context 'when the price doesn\'t exist' do
      it 'creates the price' do
        expect{ price_importer.import }.to change{ Spree::Price.count }.by(1)
      end

      it 'sets new price attributes' do
        price_importer.import
        price = Spree::Price.last
        expect(price.amount).to eq(1.0)
        expect(price.country).to be_nil
        expect(price.currency).to eq('USD')
        expect(price.seller).to eq(seller)
        expect(price.variant).to eq(variant)
      end

      it 'creates seller\'s stock item availability' do
        expect{ price_importer.import }.to change{ Spree::StockItem.count }.by(1)
        stock_item = Spree::StockItem.last
        expect(stock_item.count_on_hand).to eq(100)
        expect(stock_item.stock_location.seller).to eq(seller)
        expect(stock_item.variant).to eq(variant)
      end

      it 'creates seller\'s stock movement' do
        expect{ price_importer.import }.to change{ Spree::StockMovement.count }.by(1)
        stock_movement = Spree::StockMovement.last
        expect(stock_movement.quantity).to eq(100)
        expect(stock_movement.originator).to eq(seller)
        expect(stock_movement.stock_item.stock_location).to eq(seller.stock_location)
      end
    end

    context 'when the price exists' do
      before do
        create(:price, amount: 33.0, seller: seller, variant: variant, currency: currency)
      end

      it 'does not create a new price' do
        expect{ price_importer.import }.not_to(change{ Spree::Price.count })
      end

      it 'updates the current price' do
        create(:price, amount: 44.0, seller: seller, variant: variant, currency: currency)
        pricing_options = Spree::Variant::SellersPricingOptions.new
        expect{ price_importer.import }.to change {
          variant.price_for_seller(seller, pricing_options).money
        }.from(Spree::Money.new(44.0)).to(Spree::Money.new(1.0))
      end

      it 'updates seller\'s stock item availability' do
        stock_item = create(:stock_item, stock_location: seller.stock_location, variant: variant)
        expect{ price_importer.import }.to change{ stock_item.reload.count_on_hand }.from(10).to(100)
      end

      it 'creates seller\'s stock movement' do
        expect{ price_importer.import }.to change{ Spree::StockMovement.count }.by(1)
        stock_movement = Spree::StockMovement.last
        expect(stock_movement.quantity).to eq(100)
        expect(stock_movement.originator).to eq(seller)
        expect(stock_movement.stock_item.stock_location).to eq(seller.stock_location)
      end
    end

    context 'when the price is invalid' do
      let(:file_content) { "Sku,Price,Stock availability\n#{variant.sku},#{BigDecimal('999_999_999.99')},100\n" }

      it 'populates errors with prices errors if present' do
        expect{ price_importer.import }.to change { price_importer.errors.size }.from(0).to(1)
        expect(price_importer.errors).to include('Price must be less than or equal to 99999999.99')
      end
    end

    context 'when the sku does not exist' do
      let(:file_content) { "Sku,Price,Stock availability\nWRONG-SKU,1.0,100\n" }

      it 'populates errors with dedicated message' do
        expect(price_importer.errors).to include('WRONG-SKU is not a valid Sku')
      end
    end
  end
end
