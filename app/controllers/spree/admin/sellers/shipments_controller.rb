# frozen_string_literal: true

module Spree
  module Admin
    module Sellers
      class ShipmentsController < Spree::Admin::Sellers::ResourceController
        def index
          session[:return_to] = request.url
          @collection = @collection.reverse_chronological
          @search = @collection.ransack(params[:q])
          @collection = @search.result.page(params[:page])
          respond_with(@collection)
        end

        private

        def find_resource
          Spree::Shipment.find_by(number: params[:id])
        end

        def location_after_save
          spree.edit_admin_sellers_shipment_url(@shipment)
        end
      end
    end
  end
end
