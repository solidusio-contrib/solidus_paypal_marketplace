# frozen_string_literal: true

module Spree
  class PaypalWebhooksController < Spree::BaseController
    skip_before_action :verify_authenticity_token

    def create
      action = SolidusPaypalMarketplace::Webhooks::Sorter.call(params.permit!)
      if action[:result] == true
        render json: action, status: :ok
      else
        render json: action, status: :bad_request
      end
    end
  end
end
