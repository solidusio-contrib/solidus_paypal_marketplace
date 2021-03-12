# frozen_string_literal: true

module Spree
  module Admin
    module Sellers
      class PaypalCallbacksController < Spree::Admin::BaseController
        def create
          @seller = Spree::Seller.find_by!(merchant_id: params[:merchantId])
          if current_spree_user.seller == @seller
            if @seller.pending?
              @seller.update(merchant_id_in_paypal: params[:merchantIdInPayPal], status: :accepted)

              flash[:success] = I18n.t('spree.admin.paypal_callbacks.account_connected')
            else
              flash[:error] = I18n.t('spree.admin.paypal_callbacks.seller_already_processed')
            end
          else
            flash[:error] = I18n.t('spree.admin.paypal_callbacks.sign_up_link_not_related')
          end

          redirect_to admin_sellers_dashboard_path
        end
      end
    end
  end
end
