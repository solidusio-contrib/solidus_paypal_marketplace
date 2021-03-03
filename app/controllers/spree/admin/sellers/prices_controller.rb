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
      end
    end
  end
end
