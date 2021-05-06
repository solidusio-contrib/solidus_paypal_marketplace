# frozen_string_literal: true

module Spree
  module Admin
    module Sellers
      class ShipmentsController < Spree::Admin::Sellers::ResourceController
        before_action :refresh_payments_statuses, only: [:edit],
                                                  if: -> { params[:refresh_payments_statuses] }

        def index
          session[:return_to] = request.url
          @collection = @collection.reverse_chronological
          @search = @collection.ransack(params[:q])
          @collection = @search.result.page(params[:page])
          respond_with(@collection)
        end

        def accept
          if SolidusPaypalMarketplace::Sellers::ShipmentManagement::Accept.call(@shipment)
            flash[:success] = I18n.t('solidus_paypal_marketplace.sellers.shipment_management.accept_successfully')
          else
            flash[:error] = I18n.t('solidus_paypal_marketplace.sellers.shipment_management.accept_failed')
          end
          redirect_to spree.edit_admin_sellers_shipment_url(@shipment)
        end

        def reject
          if SolidusPaypalMarketplace::Sellers::ShipmentManagement::Reject.call(@shipment)
            flash[:success] = I18n.t('solidus_paypal_marketplace.sellers.shipment_management.reject_successfully')
          else
            flash[:error] = I18n.t('solidus_paypal_marketplace.sellers.shipment_management.reject_failed')
          end
          redirect_to spree.edit_admin_sellers_shipment_url(@shipment)
        end

        def ship
          if SolidusPaypalMarketplace::Sellers::ShipmentManagement::Ship.call(@shipment)
            flash[:success] = I18n.t('solidus_paypal_marketplace.sellers.shipment_management.ship_successfully')
          else
            flash[:error] = I18n.t('solidus_paypal_marketplace.sellers.shipment_management.ship_failed')
          end
          redirect_to spree.edit_admin_sellers_shipment_url(@shipment)
        end

        private

        def find_resource
          Spree::Shipment.find_by(number: params[:id])
        end

        def location_after_save
          spree.edit_admin_sellers_shipment_url(@shipment)
        end

        def refresh_payments_statuses
          @shipment.order.payments.map(&:source).uniq.each do |source|
            next unless source.is_a?(SolidusPaypalCommercePlatform::PaymentSource)

            SolidusPaypalMarketplace::Sellers::Captures::StatusRefresh.call(source.capture_id)
          end
        end
      end
    end
  end
end
