# frozen_string_literal: true

module Spree
  module Admin
    class SellersController < Spree::Admin::ResourceController
      def index
        session[:return_to] = request.url
        respond_with(@collection)
      end

      def start_onboarding_process
        authorize! :start_onboarding, @seller

        result = @seller.start_onboarding_process(return_url: admin_sellers_paypal_callbacks_url)

        if result.present?
          flash[:success] = I18n.t('spree.seller.start_onboarding_successfully')
        else
          flash[:error] = I18n.t('spree.seller.start_onboarding_failed')
        end

        redirect_back fallback_location: edit_admin_seller_path(@seller)
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
