# frozen_string_literal: true

seller = Spree::Seller.find_or_create_by(name: 'Seller')
product = Spree::Variant.first
variants = [product.master, *product.variants.first(2)]

variants.each do |variant|
  unless Spree::Price.where(seller: 'seller', variant: variant).exists?
    Spree::Price.create(amount: 30, seller: seller, seller_stock_availability: 100, variant: variant)
  end
end
