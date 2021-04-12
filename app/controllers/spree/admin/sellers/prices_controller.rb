# frozen_string_literal: true

require 'csv'

module Spree
  module Admin
    module Sellers
      class PricesController < Spree::Admin::Sellers::ResourceController
        include Spree::Core::ControllerHelpers::Pricing
        respond_to :html, :csv

        def index
          session[:return_to] = request.url
          @collection = @collection.currently_valid
                                   .where(currency: current_pricing_options.currency)
          respond_to do |format|
            format.html do
              @search = @collection.ransack(params[:q])
              @collection = @search.result.page(params[:page])
            end
            format.csv do
              @collection = @collection.group_by(&:variant_id).map { |_k, v| v.first }
            end
          end
        end

        private

        def flash_message_for(*args, **kwargs, &block)
          super(*args, **kwargs, &block).gsub(@object.class.model_name.human, t('spree.offer'))
        end

        def build_resource
          super.tap do |price|
            price.seller_id = spree_current_user.seller_id
          end
        end
      end
    end
  end
end
