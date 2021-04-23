# frozen_string_literal: true

SolidusPaypalMarketplace.configure do |config|
  config.paypal_client_id = ENV.fetch('PAYPAL_CLIENT_ID', nil)
  config.paypal_client_secret = ENV.fetch('PAYPAL_CLIENT_SECRET', nil)
  config.partner_code = ENV.fetch('PAYPAL_PARTNER_CODE', nil)
  config.paypal_partner_id = ENV.fetch('PAYPAL_PARTNER_ID', nil)
  config.paypal_webhook_id = ENV.fetch('PAYPAL_WEBHOOK_ID', nil)
  config.paypal_environment = PayPal::SandboxEnvironment.new(
    config.paypal_client_id,
    config.paypal_client_secret
  )
end
