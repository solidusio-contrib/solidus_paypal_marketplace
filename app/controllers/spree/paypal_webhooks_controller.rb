# frozen_string_literal: true

module Spree
  class PaypalWebhooksController < Spree::BaseController
    skip_before_action :verify_authenticity_token

    def create
      Rails.logger.warn request.inspect
      verification = SolidusPaypalMarketplace::PaypalPartnerSdk.webhook_verify(request.headers, params.permit!)
      Rails.logger.warn 'verify'
      Rails.logger.warn verification.inspect
      if verification
        result = SolidusPaypalMarketplace::Webhooks::Sorter.call(params)
        Rails.logger.warn 'sorter'
        Rails.logger.warn result.inspect
        if result
          render json: { result: result }, status: :ok
        else
          render json: { result: result }, status: :bad_request
        end
      else
        render json: { verification: verification }, status: :unauthorized
      end
    end
  end
end
