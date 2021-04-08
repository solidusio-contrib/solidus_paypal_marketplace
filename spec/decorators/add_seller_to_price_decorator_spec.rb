# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AddSellerToPriceDecorator, type: :model do
  let(:described_class) { Spree::Price }

  it do
    expect(described_class.new)
      .to belong_to(:seller)
      .class_name('Spree::Seller')
      .optional
  end

  it do
    expect(described_class.new)
      .not_to validate_presence_of(:seller)
  end

  it do
    expect(described_class).to respond_to(:with_seller)
  end

  describe '.with_seller' do
    let(:prices_with_seller) { described_class.with_seller }

    it 'includes prices with seller' do
      price = create(:price, seller: create(:seller))
      expect(prices_with_seller).to include(price)
    end

    it 'does not include prices without seller' do
      price = create(:price)
      expect(prices_with_seller).not_to include(price)
    end
  end

  context 'when seller_stock_availability is assigned' do
    it do
      expect(described_class.new(seller_stock_availability: 0))
        .to validate_presence_of(:seller)
    end
  end

  it do
    expect(described_class.new).to respond_to(:seller_stock_item)
  end

  it do
    expect(described_class.new).to respond_to(:seller_stock_availability)
  end

  it do
    expect(described_class.new).to respond_to(:seller_stock_availability=)
  end

  describe 'seller_stock_item' do
    let(:price) { described_class.new(seller: seller) }
    let(:seller) { nil }
    let(:seller_stock_item) { price.seller_stock_item }

    context 'when seller is blank' do
      it do
        expect(seller_stock_item).to be nil
      end
    end

    context 'when seller is present' do
      let(:seller) { create(:seller) }

      it do
        expect(seller_stock_item).to be_kind_of(Spree::StockItem)
      end

      it 'matches price\'s variant' do
        expect(seller_stock_item.variant).to eq(price.variant)
      end

      it 'matches sellers\'s stock_location' do
        expect(seller_stock_item.stock_location).to eq(seller.stock_location)
      end
    end
  end

  describe 'seller stock availability' do
    let(:price) { create(:price, seller: seller) }
    let(:seller) { nil }
    let(:seller_stock_availability) { price.seller_stock_availability }

    context 'when seller is blank' do
      it do
        expect(seller_stock_availability).to be nil
      end

      it 'cannot be set' do
        price.update(seller_stock_availability: 20)
        expect(
          price.errors.added?(:seller, :blank)
        ).to be true
      end
    end

    context 'when seller is present' do
      let(:seller) { create(:seller) }

      it 'is 0 if variant stock item is blank' do
        expect(seller_stock_availability).to be 0
      end

      it 'equals seller stock location variant availability' do
        stock_item = create(:stock_item, stock_location_id: seller.stock_location.id, variant_id: price.variant_id)
        stock_item.set_count_on_hand(20)
        expect(seller_stock_availability).to equal 20
      end

      it 'can be set' do
        price.update(seller_stock_availability: 20)
        expect(seller_stock_availability).to equal 20
      end

      it 'persists stock item when saved' do
        expect { price.update(seller_stock_availability: 20) }
          .to change { price.seller_stock_item.persisted? }
          .from(false)
          .to(true)
      end

      it 'create stock movement when stock availability is updated' do
        current_availability = price.seller_stock_availability
        expect { price.update(seller_stock_availability: current_availability + 10) }
          .to change { Spree::StockMovement.count }.by(1)
        movement = Spree::StockMovement.last
        expect(movement.quantity).to eq(10)
        expect(movement.stock_item).to eq(price.seller_stock_item)
      end

      it 'does not create stock movement when stock avaibility is not updated' do
        current_availability = price.seller_stock_availability
        current_amount = price.amount
        expect { price.update(amount: current_amount + 10, seller_stock_availability: current_availability) }
          .not_to(change { Spree::StockMovement.count })
      end

      it 'does not create stock movement when stock avaibility is created at 0' do
        price.seller_stock_item.destroy!
        expect { price.update(seller_stock_availability: 0) }
          .not_to(change { Spree::StockMovement.count })
      end

      it 'raises an exception if new count is less than 0' do
        expect { price.update(seller_stock_availability: -1) }
          .to raise_exception(Spree::StockLocation::InvalidMovementError)
      end
    end
  end
end
