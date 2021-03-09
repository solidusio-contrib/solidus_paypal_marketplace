# frozen_string_literal: true

unless Spree::Seller.where(name: 'Seller').exists?
  Spree::Seller.create!(name: 'Seller', percentage: 20)
end
