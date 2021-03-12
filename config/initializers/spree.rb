# frozen_string_literal: true

Spree.config do |config|
  config.roles.assign_permissions :seller, [
    'Spree::PermissionSets::Seller',
    'Spree::PermissionSets::PaypalCallbacks'
  ]
  config.roles.assign_permissions :admin, ['Spree::PermissionSets::PaypalCallbacks']
end

Spree::Backend::Config.configure do |config|
  config.menu_items << config.class::MenuItem.new(
    [:sellers],
    'briefcase',
    condition: -> { can?(:read, Spree::Seller) },
    url: :admin_sellers_path
  )
  config.menu_items << config.class::MenuItem.new(
    [:offers],
    'list',
    condition: -> { can?(:read, Spree::Price) && current_spree_user.has_spree_role?('seller') },
    url: :admin_sellers_prices_path
  )
end
