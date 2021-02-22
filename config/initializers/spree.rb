# frozen_string_literal: true

Spree::Backend::Config.configure do |config|
  config.menu_items << config.class::MenuItem.new(
    [:sellers],
    'briefcase',
    url: :admin_sellers_path
  )
end
