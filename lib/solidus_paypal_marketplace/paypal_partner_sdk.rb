# frozen_string_literal: true

require 'solidus_paypal_marketplace/paypal_partner_sdk/create_partner_referral'
require 'solidus_paypal_marketplace/paypal_partner_sdk/show_captured_payment_details'
require 'solidus_paypal_marketplace/paypal_partner_sdk/show_seller_status'

module SolidusPaypalMarketplace
  module PaypalPartnerSdk
    module_function

    def generate_paypal_sign_up_link(tracking_id: nil, return_url: nil)
      request = CreatePartnerReferral.new(tracking_id: tracking_id, return_url: return_url)
      response = SolidusPaypalMarketplace::PaypalPartnerSdk.execute(request)
      return unless response

      response.result.links.detect { |l| l.rel == 'action_url' }.href
    end

    def show_captured_payment_details(capture_id:)
      request = ShowCapturedPaymentDetails.new(capture_id: capture_id)
      response = SolidusPaypalMarketplace::PaypalPartnerSdk.execute(request)
      return unless response

      response.result
    end

    def show_seller_status(merchant_id:)
      request = ShowSellerStatus.new(merchant_id: merchant_id)
      response = SolidusPaypalMarketplace::PaypalPartnerSdk.execute(request)
      return unless response

      response.result
    end

    def execute(request)
      SolidusPaypalMarketplace.client.execute(request)
    rescue PayPalHttp::HttpError => e
      Rails.logger.error e.status_code
      Rails.logger.error e.headers
      Rails.logger.error e.result
      nil
    end
  end
end
