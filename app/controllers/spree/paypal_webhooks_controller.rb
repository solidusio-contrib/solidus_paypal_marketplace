# frozen_string_literal: true

module Spree
  class PaypalWebhooksController < Spree::BaseController
    skip_before_action :verify_authenticity_token

    def create
      params.permit!
      verification = SolidusPaypalMarketplace::PaypalPartnerSdk.webhook_verify(request.headers, params)
      if verification
        action = SolidusPaypalMarketplace::Webhooks::Sorter.call(params)
        if action[:result] == true
          render json: action, status: :ok
        else
          render json: action, status: :bad_request
        end
      else
        render json: { verification: verification }, status: :unauthorized
      end
    end
  end
end
