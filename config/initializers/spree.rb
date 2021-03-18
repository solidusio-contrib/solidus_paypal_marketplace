# frozen_string_literal: true

Spree.config do |config|
  config.roles.assign_permissions :seller, [
    'Spree::PermissionSets::Seller',
    'Spree::PermissionSets::Offer'
  ]
  config.roles.assign_permissions :admin, [
    'Spree::PermissionSets::Admin'
  ]
end

Spree::Backend::Config.configure do |config|
  config.menu_items << config.class::MenuItem.new(
    [:sellers],
    'briefcase',
    condition: -> { can?(:read, Spree::Seller) },
    url: :admin_sellers_path
  )
  config.menu_items << config.class::MenuItem.new(
    [:dashboard],
    'list',
    condition: -> { can?(:visit, :seller_dashboard) },
    url: :admin_sellers_dashboard_path
  )
  config.menu_items << config.class::MenuItem.new(
    [:offers],
    'list',
    condition: -> {
      can?(:visit, :seller_prices)
    },
    url: :admin_sellers_prices_path
  )
end
