# frozen_string_literal: true

module Spree
  class PaypalWebhooksController < Spree::BaseController
    skip_before_action :verify_authenticity_token

    def create
      result = SolidusPaypalMarketplace::Webhooks::Sorter.call(params.permit!)
      if result
        render json: { result: result }, status: :ok
      else
        render json: { result: result }, status: :bad_request
      end
    end
  end
end
