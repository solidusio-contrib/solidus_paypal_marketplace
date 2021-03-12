# frozen_string_literal: true

module Spree
  module Admin
    module Sellers
      class PricesController < Spree::Admin::Sellers::ResourceController
        def index
          session[:return_to] = request.url
          @search = @collection.ransack(params[:q])
          @collection = @search.result.page(params[:page])
          respond_with(@collection)
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
