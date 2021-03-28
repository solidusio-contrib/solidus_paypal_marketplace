# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Stock::MarketplaceCoordinator, type: :model do
  describe '#shipments' do
    subject(:shipments) { described_class.new(order).shipments }

    let(:variant) { first_price.variant }

    let(:first_price) { create(:price, seller: create(:seller)) }
    let(:first_seller) { first_price.seller }
    let(:first_line_item_stock) { 0 }
    let!(:first_stock_location) { create(:stock_location, propagate_all_variants: true, seller: first_seller) }

    let(:line_item) { create(:line_item, variant: variant, seller: first_seller) }
    let(:order) { line_item.order }

    before do
      Spree::StockItem.find_by(variant_id: variant.id, stock_location_id: first_stock_location.id).tap do |si|
        si.set_count_on_hand(first_line_item_stock)
        si.update(backorderable: false)
      end

      line_item
    end

    it { expect { shipments }.to raise_error(Spree::Order::InsufficientStock) }

    context 'when the item is available' do
      let(:first_line_item_stock) { 1 }

      it 'creates one shipment for the selected stock location' do
        expect(shipments.first.stock_location).to eq first_stock_location
      end
    end

    context 'with one line item for one variant that has 2 price from 2 different vendor' do
      let(:second_price) { create(:price, variant: first_price.variant, seller: create(:seller)) }
      let(:second_seller) { second_price.seller }
      let(:second_line_item_stock) { 0 }
      let!(:second_stock_location) { create(:stock_location, propagate_all_variants: true, seller: second_seller) }

      let(:line_item2) do
        build(:line_item, order: line_item.order, variant: variant, seller: second_seller).tap do |li|
          allow(li).to receive(:reject_price_from_different_seller).and_return(true)
          li.save!
        end
      end

      before do
        Spree::StockItem.find_by(variant_id: variant.id, stock_location_id: second_stock_location.id).tap do |si|
          si.set_count_on_hand(second_line_item_stock)
          si.update(backorderable: false)
        end

        line_item2
      end

      it { expect { shipments }.to raise_error(Spree::Order::InsufficientStock) }

      context 'when stock item has sufficient stock only in one stock item' do
        let(:first_line_item_stock) { 10 }

        it { expect { shipments }.to raise_error(Spree::Order::InsufficientStock) }

        context 'when stock item has sufficient stock for both stock items' do
          let(:second_line_item_stock) { 10 }

          it { expect(shipments.size).to eq 2 }

          it 'links the two shipments with the related stock_location' do
            expect(shipments).to match array_including(
              have_attributes(stock_location_id: first_stock_location.id),
              have_attributes(stock_location_id: second_stock_location.id),
            )
          end
        end
      end
    end
  end
end
