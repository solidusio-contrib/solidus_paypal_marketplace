# frozen_string_literal: true

module Spree
  module Admin
    class SellersController < Spree::Admin::ResourceController
      def index
        session[:return_to] = request.url
        respond_with(@collection)
      end

      private

      def collection
        return @collection if @collection.present?

        @collection = super
        @search = @collection.ransack(params[:q])
        @collection = @search.result.page(params[:page])
      end
    end
  end
end
