# frozen_string_literal: true

module ReturnLowestSellerPriceInProductPriceForDecorator
  def price_for(price_options)
    prices = prices_for_variants(price_options).compact

    return min_prices(prices) if prices.present?

    price_for_master(price_options)
  end

  def min_prices(prices)
    return prices.min_by(&:money) if ::Spree.solidus_gem_version >= Gem::Version.new('3.1.0.alpha')

    prices.min
  end

  def price_for_master(price_options)
    find_or_build_master.lowest_seller_price_for(price_options)
  end

  def prices_for_variants(price_options)
    variants.map do |variant|
      variant.lowest_seller_price_for(price_options)
    end
  end

  def price_for_options(pricing_options)
    price_for(pricing_options)
  end

  Spree::Product.prepend self
end
