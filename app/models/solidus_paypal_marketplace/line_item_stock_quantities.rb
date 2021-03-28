# frozen_string_literal: true

module SolidusPaypalMarketplace
  # A value object to hold a map of line_items to their quantities
  class LineItemStockQuantities
    attr_reader :quantities

    # @param quantities [Hash<Spree::LineItem=>Numeric>]
    def initialize(quantities = {})
      raise ArgumentError unless quantities.keys.all? { |v| v.is_a?(Spree::LineItem) }
      raise ArgumentError unless quantities.values.all? { |v| v.is_a?(Numeric) }

      @quantities = quantities
    end

    # @yield [line_item, quantity]
    def each(&block)
      @quantities.each(&block)
    end

    # @param line_item [Spree::LineItem]
    # @return [Integer] the quantity of line_item
    def [](line_item)
      @quantities[line_item]
    end

    # @return [Array<Spree::LineItem>] the line_items being tracked
    def line_items
      @quantities.keys.uniq
    end

    # Adds two StockQuantities together
    # @return [Spree::StockQuantities]
    def +(other)
      combine_with(other) do |_line_item, a, b|
        (a || 0) + (b || 0)
      end
    end

    # Subtracts another StockQuantities from this one
    # @return [Spree::StockQuantities]
    def -(other)
      combine_with(other) do |_line_item, a, b|
        (a || 0) - (b || 0)
      end
    end

    # Finds the intersection or common subset of two StockQuantities: the
    # stock which exists in both StockQuantities.
    # @return [Spree::StockQuantities]
    def &(other)
      combine_with(other) do |_line_item, a, b|
        next unless a && b

        [a, b].min
      end
    end

    # A StockQuantities is empty if all line_items have zero quantity
    # @return [true,false]
    def empty?
      @quantities.values.all?(&:zero?)
    end

    def any?
      !empty?
    end

    def ==(other)
      self.class == other.class &&
        quantities == other.quantities
    end

    protected

    def combine_with(other)
      self.class.new(
        (line_items | other.line_items).map do |line_item|
          a = self[line_item]
          b = other[line_item]
          value = yield line_item, a, b
          [line_item, value]
        end.to_h.compact
      )
    end
  end
end
