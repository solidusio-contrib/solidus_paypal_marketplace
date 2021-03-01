# frozen_string_literal: true

module AddSellerToStockLocationDecorator
  def self.prepended(base)
    base.belongs_to :seller, class_name: 'Spree::Seller',
                             optional: true
  end

  Spree::StockLocation.prepend self
end
