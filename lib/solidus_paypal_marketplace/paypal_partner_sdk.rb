# frozen_string_literal: true

require 'solidus_paypal_marketplace/paypal_partner_sdk/create_partner_referral'
require 'solidus_paypal_marketplace/paypal_partner_sdk/show_seller_status'
require 'solidus_paypal_marketplace/paypal_partner_sdk/webhook_verify'

module SolidusPaypalMarketplace
  module PaypalPartnerSdk
    module_function

    def generate_paypal_sign_up_link(tracking_id: nil, return_url: nil)
      request = CreatePartnerReferral.new(tracking_id: tracking_id, return_url: return_url)
      response = SolidusPaypalMarketplace::PaypalPartnerSdk.execute(request)
      return unless response

      response.result.links.detect { |l| l.rel == 'action_url' }.href
    end

    def show_seller_status(merchant_id:)
      request = ShowSellerStatus.new(merchant_id: merchant_id)
      response = SolidusPaypalMarketplace::PaypalPartnerSdk.execute(request)
      return unless response

      response.result
    end

    def webhook_verify(headers, params)
      request = ::SolidusPaypalMarketplace::PaypalPartnerSdk::WebhookVerify.new(
        headers: headers,
        params: params
      )
      response = SolidusPaypalMarketplace::PaypalPartnerSdk.execute(request)
      return false unless response&.status_code == '200'

      data = JSON.parse(response.body)
      data['verification_status'] == "SUCCESS"
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
