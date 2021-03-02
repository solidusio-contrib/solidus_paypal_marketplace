# frozen_string_literal: true

module AddSellerToPriceDecorator
  def self.prepended(base)
    base.belongs_to :seller, class_name: 'Spree::Seller',
                             optional: true
  end

  Spree::Price.prepend self
end
