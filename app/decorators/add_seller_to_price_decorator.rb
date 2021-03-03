# frozen_string_literal: true

module AddSellerToPriceDecorator
  def self.prepended(base)
    base.belongs_to :seller, class_name: 'Spree::Seller',
                             optional: true

    base.validates :seller, presence: true,
                            if: -> { @seller_stock_availability }

    base.after_save :save_seller_stock_availability, if: -> { @seller_stock_availability }
  end

  def seller_stock_item
    return nil if seller.blank?

    Spree::StockItem.find_or_initialize_by(stock_location_id: seller.stock_location.id, variant_id: variant_id)
  end

  def seller_stock_availability
    return nil if seller.blank?

    return 0 if seller_stock_item.blank?

    seller_stock_item.count_on_hand
  end

  def seller_stock_availability=(value)
    @seller_stock_availability = value
  end

  def save_seller_stock_availability
    seller_stock_item.set_count_on_hand(@seller_stock_availability)
  end

  Spree::Price.prepend self
end
