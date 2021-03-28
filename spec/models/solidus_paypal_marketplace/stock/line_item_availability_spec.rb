# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Stock::LineItemAvailability do
  subject { availability }

  let(:line_items) { Spree::LineItem.all.to_a }
  let(:infinity) { Float::INFINITY }

  let(:availability) { described_class.new(line_items: line_items) }
  let(:seller) { create(:seller, stock_location: stock_location1) }
  let(:stock_location1) { build(:stock_location, propagate_all_variants: true) }

  describe "#on_hand_by_stock_location_id" do
    subject(:on_hand_by_stock_location_id!) { availability.on_hand_by_stock_location_id }

    context 'with a single variant' do
      let(:price) { create(:price, seller: seller, amount: 10) }
      let(:variant) do
        price.variant
      end
      let(:stock_item) { variant.stock_items[0] }
      let!(:line_item) do
        create(:line_item, price: price.amount, variant: variant, seller: seller)
      end

      context 'with count_on_hand positive' do
        before { stock_item.set_count_on_hand(2) }

        it "returns the correct value" do
          on_hand_by_stock_location_id!
          expect(on_hand_by_stock_location_id!).to eq(
            stock_location1.id => SolidusPaypalMarketplace::LineItemStockQuantities.new(line_item => 2)
          )
        end

        context 'when backorderable is false' do
          before { stock_item.update!(backorderable: false) }

          it "returns the correct value" do
            expect(on_hand_by_stock_location_id!).to eq(
              stock_location1.id => SolidusPaypalMarketplace::LineItemStockQuantities.new(line_item => 2)
            )
          end
        end

        context 'when there are more than one stock location in the same order' do
          let(:seller2) { create(:seller, stock_location: stock_location2) }
          let(:stock_location2) { create(:stock_location, propagate_all_variants: true) }
          let(:stock_item2) { variant.stock_items.find_by!(stock_location: stock_location2) }
          let(:price2) { create(:price, seller: seller2, amount: 10, variant: price.variant) }
          let(:line_item2) do
            build(:line_item, price: price2.amount, variant: variant, seller: seller2, order: line_item.order)
          end

          before do
            line_item2
            allow(line_item2).to receive(:reject_price_from_different_seller).and_return(true)
            line_item2.save

            stock_item.set_count_on_hand(2)
            stock_item2.set_count_on_hand(4)
          end

          it 'returns the right quantities for line item' do
            expect(availability.on_hand_by_stock_location_id)
              .to eq(
                stock_location1.id => SolidusPaypalMarketplace::LineItemStockQuantities.new(line_item => 2),
                stock_location2.id => SolidusPaypalMarketplace::LineItemStockQuantities.new(line_item2 => 4)
              )
          end
        end
      end

      context 'with count_on_hand 0' do
        before { stock_item.set_count_on_hand(0) }

        it "returns zero on_hand" do
          expect(on_hand_by_stock_location_id!).to eq(
            stock_location1.id => SolidusPaypalMarketplace::LineItemStockQuantities.new(line_item => 0)
          )
        end
      end

      context 'with count_on_hand negative' do
        before { stock_item.set_count_on_hand(-1) }

        it "returns zero on_hand" do
          expect(on_hand_by_stock_location_id!).to eq(
            stock_location1.id => SolidusPaypalMarketplace::LineItemStockQuantities.new(line_item => 0)
          )
        end
      end

      context 'with no stock_item' do
        before { stock_item.destroy! }

        it "returns empty hash" do
          expect(on_hand_by_stock_location_id!).to eq({})
        end
      end

      context 'with soft-deleted stock_item' do
        before { stock_item.discard }

        it "returns empty hash" do
          expect(on_hand_by_stock_location_id!).to eq({})
        end
      end

      context 'with track_inventory=false' do
        before { variant.update!(track_inventory: false) }

        it "has infinite inventory " do
          expect(on_hand_by_stock_location_id!).to eq(
            stock_location1.id => SolidusPaypalMarketplace::LineItemStockQuantities.new(line_item => infinity)
          )
        end
      end

      context 'with config.track_inventory_levels=false' do
        before { stub_spree_preferences(track_inventory_levels: false) }

        it "has infinite inventory " do
          expect(on_hand_by_stock_location_id!).to eq(
            stock_location1.id => SolidusPaypalMarketplace::LineItemStockQuantities.new(line_item => infinity)
          )
        end
      end
    end
  end

  describe "#backorderable_by_stock_location_id" do
    subject { availability.backorderable_by_stock_location_id }

    context 'with a single variant' do
      let!(:line_item) do
        create(:line_item, price: price.amount, variant: variant, seller: seller)
      end
      let!(:variant) { price.variant }
      let(:stock_item) { variant.stock_items[0] }
      let(:price) { create(:price, seller: seller, amount: 10) }

      context 'with backorderable false' do
        before { stock_item.update!(backorderable: false) }

        context 'with positive count_on_hand' do
          before { stock_item.set_count_on_hand(2) }

          it { is_expected.to eq({}) }
        end

        context 'with 0 count_on_hand' do
          before { stock_item.set_count_on_hand(0) }

          it { is_expected.to eq({}) }
        end
      end

      context 'with backorderable true' do
        before { stock_item.update!(backorderable: true) }

        let(:expected_line_item_stock_quantities) do
          SolidusPaypalMarketplace::LineItemStockQuantities.new(line_item => infinity)
        end

        context 'with positive count_on_hand' do
          before { stock_item.set_count_on_hand(2) }

          it { is_expected.to eq(stock_location1.id => expected_line_item_stock_quantities) }
        end

        context 'with 0 count_on_hand' do
          before { stock_item.set_count_on_hand(0) }

          it { is_expected.to eq(stock_location1.id => expected_line_item_stock_quantities) }
        end

        context 'with negative count_on_hand' do
          before { stock_item.set_count_on_hand(-1) }

          it { is_expected.to eq(stock_location1.id => expected_line_item_stock_quantities) }
        end
      end

      context 'with soft-deleted stock_item' do
        before { stock_item.discard }

        it { is_expected.to eq({}) }
      end

      context 'with no stock_item' do
        before { stock_item.destroy }

        it { is_expected.to eq({}) }
      end
    end
  end
end
