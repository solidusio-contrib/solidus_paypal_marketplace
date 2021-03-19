# frozen_string_literal: true

require 'solidus_paypal_marketplace/paypal_partner_sdk/create_partner_referral'

module SolidusPaypalMarketplace
  module PaypalPartnerSdk
    module_function

    def generate_paypal_sign_up_link(tracking_id: nil, return_url: nil)
      request = CreatePartnerReferral.new(tracking_id: tracking_id, return_url: return_url)

      response = SolidusPaypalMarketplace.client.execute(request)

      response.result.links.detect { |l| l.rel == 'action_url' }.href
    rescue PayPalHttp::HttpError => e
      Rails.logger.error e.status_code
      Rails.logger.error e.headers['paypal-debug-id']
      Rails.logger.error e.result.error_description
      Rails.logger.error e.result.error
      nil
    end
  end
end
