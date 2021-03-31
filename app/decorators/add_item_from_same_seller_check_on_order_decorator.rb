# frozen_string_literal: true

module AddItemFromSameSellerCheckOnOrderDecorator
  class OptionSellerIdRequired < StandardError; end

  def self.prepended(base)
    base.register_line_item_comparison_hook(:item_from_same_seller)
  end

  def item_from_same_seller(line_item, options)
    raise OptionSellerIdRequired, 'Line item seller id is required' if options[:options][:seller_id].nil?

    line_item.seller_id == options[:options][:seller_id].to_i
  end

  Spree::Order.prepend self
end
