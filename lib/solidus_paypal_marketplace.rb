# frozen_string_literal: true

require 'solidus_paypal_marketplace/http_client'
require 'solidus_paypal_marketplace/configuration'
require 'solidus_paypal_marketplace/version'
require 'solidus_paypal_marketplace/engine'
require 'solidus_paypal_commerce_platform'

module SolidusPaypalMarketplace
  module_function

  def client
    @client ||= SolidusPaypalMarketplace::HTTPClient.new.client
  end
end
