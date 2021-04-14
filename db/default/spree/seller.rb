# frozen_string_literal: true

unless Spree::Seller.where(name: 'Seller').exists?
  status = ENV['DEFAULT_MERCHANT_ID'] && ENV['DEFAULT_MERCHANT_ID_IN_PAYPAL'] ? :accepted : :pending
  Spree::Seller.create!(
    name: 'Seller',
    percentage: 20,
    merchant_id: ENV['DEFAULT_MERCHANT_ID'],
    merchant_id_in_paypal: ENV['DEFAULT_MERCHANT_ID_IN_PAYPAL'],
    status: status
  )
end
if ENV['SELLER_SEEDS'].present?
  seeds = JSON.parse(ENV['SELLER_SEEDS'])
  seeds.each.with_index do |seed, index|
    name = seed['name'] || index
    Spree::Seller.find_or_initialize_by(name: name).tap do |seller|
      seller.percentage = seed['percentage'] || 10
      seller.merchant_id = seed['merchant_id']
      seller.merchant_id_in_paypal = seed['merchant_id_in_paypal']
      status = seller.merchant_id && seller.merchant_id_in_paypal ? :accepted : :pending
      seller.status = status
      seller.save
    end
  end
end
