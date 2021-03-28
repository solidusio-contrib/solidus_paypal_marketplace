# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Stock
    class MarketplaceCoordinator < Spree::Stock::SimpleCoordinator
      attr_reader :order

      def initialize(order, inventory_units = nil) # rubocop:disable Lint/MissingSuper
        @order = order
        @inventory_units = inventory_units || Spree::Stock::InventoryUnitBuilder.new(order).units
        @splitters = Spree::Config.environment.stock_splitters

        filtered_stock_locations = Spree::Config.stock.location_filter_class.new(
          Spree::StockLocation.all, @order
        ).filter
        sorted_stock_locations = Spree::Config.stock.location_sorter_class.new(filtered_stock_locations).sort
        @stock_locations = sorted_stock_locations

        @inventory_units_by_line_item = @inventory_units.group_by(&:line_item)
        @desired = SolidusPaypalMarketplace::LineItemStockQuantities.new(
          @inventory_units_by_line_item.transform_values(&:count)
        )
        @availability = SolidusPaypalMarketplace::Stock::LineItemAvailability.new(
          line_items: @desired.line_items,
          stock_locations: @stock_locations
        )

        @allocator = Spree::Config.stock.allocator_class.new(@availability)
      end

      def get_units(quantities)
        quantities.quantities.flat_map do |line_item, quantity|
          @inventory_units_by_line_item[line_item].shift(quantity)
        end
      end
    end
  end
end
