# frozen_string_literal: true

module PreventSellersStockLocationDestructionDecorator
  def self.prepended(base)
    base.before_destroy do
      if seller.present?
        errors.add(:base, :cannot_destroy_sellers_stock_location)
        throw(:abort)
      end
    end
  end

  Spree::StockLocation.prepend self
end
