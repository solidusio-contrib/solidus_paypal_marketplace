# frozen_string_literal: true

module ReturnLowestSellerPriceInProductPriceForDecorator
  def price_for(price_options)
    prices = prices_for_variants(price_options).compact
    return prices.min if prices.present?

    price_for_master(price_options)
  end

  def price_for_master(price_options)
    find_or_build_master.lowest_seller_price_for(price_options)
  end

  def prices_for_variants(price_options)
    variants.map do |variant|
      variant.lowest_seller_price_for(price_options)
    end
  end

  Spree::Product.prepend self
end