# frozen_string_literal: true

module AddPriceForSellerToVariantDecorator
  def self.prepended(base)
    base.delegate :price_for_seller, to: :price_selector
  end

  Spree::Variant.prepend self
end
