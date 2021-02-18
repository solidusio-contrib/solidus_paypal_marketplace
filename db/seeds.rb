# frozen_string_literal: true

puts "Loading seed file: solidus_paypal_marketplace/roles"  # rubocop:disable Rails/Output
unless Spree::Role.where(name: 'seller').exists?
  Spree::Role.create!(name: 'seller')
end
