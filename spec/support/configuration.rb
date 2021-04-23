# frozen_string_literal: true

SolidusPaypalMarketplace.configure do |config|
  config.paypal_client_id = ENV.fetch('PAYPAL_CLIENT_ID')
  config.paypal_client_secret = ENV.fetch('PAYPAL_CLIENT_SECRET')
  config.partner_code = ENV.fetch('PAYPAL_PARTNER_CODE')
  config.partner_code = ENV.fetch('PAYPAL_PARTNER_ID')
  config.paypal_webhook_id = ENV.fetch('PAYPAL_WEBHOOK_ID')
end
