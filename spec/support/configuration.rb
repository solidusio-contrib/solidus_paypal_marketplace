# frozen_string_literal: true

SolidusPaypalMarketplace.configure do |config|
  config.paypal_client_id = ENV['PAYPAL_CLIENT_ID']
  config.paypal_client_secret = ENV['PAYPAL_CLIENT_SECRET']
  config.partner_code = ENV['PAYPAL_PARTNER_CODE']
end
