# frozen_string_literal: true

module Spree
  module Admin
    module Sellers
      class PricesController < Spree::Admin::ResourceController
        def index
          session[:return_to] = request.url
          @search = @collection.ransack(params[:q])
          @collection = @search.result.page(params[:page])
          respond_with(@collection)
        end

        private

        def build_resource
          super.tap do |price|
            price.seller_id = spree_current_user.seller_id
          end
        end
      end
    end
  end
end
