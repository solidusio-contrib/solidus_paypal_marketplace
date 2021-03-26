# frozen_string_literal: true

seller = Spree::Seller.find_or_create_by(name: 'Seller')

products = Spree::Product.includes(:variants).all.group_by do |product|
  product.variants.present? ? :with_variants : :without_variants
end

product = products[:with_variants].first
variants = [*product.variants.first(2)]
product = products[:without_variants].first
variants << product.master

variants.each do |variant|
  unless Spree::Price.where(seller: 'seller', variant: variant).exists?
    Spree::Price.create(amount: 30, seller: seller, seller_stock_availability: 100, variant: variant)
  end
end
