# frozen_string_literal: true

module AddSellerToLineItemDecorator
  def self.prepended(base)
    base.belongs_to :seller, class_name: 'Spree::Seller'
  end

  Spree::LineItem.prepend self
end
