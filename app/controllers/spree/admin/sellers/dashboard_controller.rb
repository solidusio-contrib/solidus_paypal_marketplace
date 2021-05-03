# frozen_string_literal: true

module Spree
  module Admin
    module Sellers
      class DashboardController < Spree::Admin::BaseController
        skip_before_action :authorize_admin

        def show
          authorize! :visit, :seller_dashboard

          @seller = current_spree_user.seller
          refresh_seller_status if params[:refresh_seller_status]
          render locals: @locals || {}
        end

        private

        def refresh_seller_status
          seller_status = SolidusPaypalMarketplace::Sellers::StatusRefresh.call(
            @seller, return_url: admin_sellers_paypal_callbacks_url
          )
          restart_onboarding_process if seller_status.wrong_oauth_third_party_permissions
          @seller.reload
          @locals = {
            unconfirmed_primary_email: seller_status.unconfirmed_primary_email,
            wrong_oauth_third_party_permissions: seller_status.wrong_oauth_third_party_permissions
          }
        end
      end
    end
  end
end
