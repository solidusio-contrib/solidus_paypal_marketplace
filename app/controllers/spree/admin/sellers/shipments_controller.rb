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
      end
    end
  end
end
