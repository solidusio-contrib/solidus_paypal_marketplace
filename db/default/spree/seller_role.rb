# frozen_string_literal: true

unless Spree::Role.where(name: 'seller').exists?
  Spree::Role.create!(name: 'seller')
end
