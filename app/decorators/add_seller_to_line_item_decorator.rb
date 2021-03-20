# frozen_string_literal: true

module AddSellerToLineItemDecorator
  def self.prepended(base)
    base.belongs_to :seller, class_name: 'Spree::Seller'
    base.validate :validate_seller_price_presence, if: -> { variant.present? }
  end

  private

  def validate_seller_price_presence
    pricing_options = Spree::Variant::PricingOptions.from_line_item(self)
    errors.add(:seller, :no_prices) if variant.price_for_seller(seller, pricing_options).nil?
  end

  Spree::LineItem.prepend self
end
