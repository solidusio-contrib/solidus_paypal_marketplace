# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Stock
    class LineItemAvailability < Spree::Stock::Availability
      def initialize(line_items:, stock_locations: Spree::StockLocation.active) # rubocop:disable Lint/MissingSuper
        @variants = line_items.map(&:variant).uniq

        @line_items = line_items
        @line_item_map = line_items.index_by { |li| [li.variant_id, li.seller&.stock_location&.id] }
        @stock_locations = stock_locations
      end

      def on_hand_by_stock_location_id
        counts_on_hand.to_a.group_by do |(_, stock_location_id), _|
          stock_location_id
        end.transform_values do |values|
          SolidusPaypalMarketplace::LineItemStockQuantities.new(line_item_stock_quantity(values))
        end
      end

      def backorderable_by_stock_location_id
        backorderables.group_by(&:second).transform_values do |variant_stock_locations|
          SolidusPaypalMarketplace::LineItemStockQuantities.new(
            variant_stock_locations.map do |variant_id, stock_location_id|
              line_item = @line_item_map[[variant_id, stock_location_id]]
              next if line_item.nil?

              [line_item, Float::INFINITY]
            end.compact.to_h
          )
        end
      end

      private

      def line_item_stock_quantity(inventory_on_hand_grouped_by_stock_location)
        inventory_on_hand_grouped_by_stock_location.map do |(variant_id, stock_location_id), count|
          line_item = @line_item_map[[variant_id, stock_location_id]]
          next if line_item.nil?

          count = Float::INFINITY if !line_item.variant.should_track_inventory?
          count = 0 if count.negative?
          [line_item, count]
        end.compact.to_h
      end

      def stock_item_scope
        Spree::StockItem
          .joins(:stock_location, variant: :prices)
          .where('spree_prices.seller_id = spree_stock_locations.seller_id')
          .where(variant_id: @variants, stock_location_id: @stock_locations)
      end
    end
  end
end
