# frozen_string_literal: true

Spree.config do |config|
  config.roles.assign_permissions :seller, ['Spree::PermissionSets::Seller']
end

Spree::Backend::Config.configure do |config|
  config.menu_items << config.class::MenuItem.new(
    [:sellers],
    'briefcase',
    condition: -> { can?(:read, Spree::Seller) },
    url: :admin_sellers_path
  )
  config.menu_items << config.class::MenuItem.new(
    [:prices],
    'money',
    condition: -> { can?(:read, Spree::Price) },
    url: :admin_prices_path
  )
end
