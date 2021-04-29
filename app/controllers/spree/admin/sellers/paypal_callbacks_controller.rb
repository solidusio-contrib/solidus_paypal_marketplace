# frozen_string_literal: true

module Spree
  module Admin
    module Sellers
      class PaypalCallbacksController < Spree::Admin::BaseController
        skip_before_action :authorize_admin

        def show
          authorize! :visit, :paypal_callbacks

          @seller = Spree::Seller.find_by!(merchant_id: params[:merchantId])

          if current_spree_user.seller == @seller
            if params[:permissionsGranted] == 'true'
              if @seller.pending?
                @seller.update(
                  merchant_id_in_paypal: params[:merchantIdInPayPal],
                  status: :waiting_paypal_confirmation
                )

                flash[:success] = I18n.t('spree.admin.paypal_callbacks.waiting_webhook_confirmation')
              else
                flash[:error] = I18n.t('spree.admin.paypal_callbacks.seller_already_processed')
              end
            else
              @seller.start_onboarding_process(return_url: admin_sellers_paypal_callbacks_url)
              flash[:error] = I18n.t('spree.admin.paypal_callbacks.granted_permissions_insufficient')
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
