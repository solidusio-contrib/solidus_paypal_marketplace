# frozen_string_literal: true

require 'spec_helper'

describe SolidusPaypalMarketplace::Configuration do
  before do
    SolidusPaypalMarketplace.configure do |config|
      config.paypal_client_id = 'sb-user@business.example.com'
      config.paypal_client_secret = 'secret-stuff'
      config.partner_code = 'paypal-partner-code'
      config.paypal_partner_id = 'paypal-partner-id'
      config.paypal_webhook_id = 'paypal-webhook-id'
    end
  end

  it 'read paypal_client_id value' do
    expect(SolidusPaypalMarketplace.config.paypal_client_id).to be 'sb-user@business.example.com'
  end

  it 'read paypal_client_secret value' do
    expect(SolidusPaypalMarketplace.config.paypal_client_secret).to be 'secret-stuff'
  end

  it 'read partner_code value' do
    expect(SolidusPaypalMarketplace.config.partner_code).to be 'paypal-partner-code'
  end

  it 'read partner_id value' do
    expect(SolidusPaypalMarketplace.config.paypal_partner_id).to be 'paypal-partner-id'
  end

  it 'read webhook_id value' do
    expect(SolidusPaypalMarketplace.config.paypal_webhook_id).to be 'paypal-webhook-id'
  end
end
