# frozen_string_literal: true

module Spree
  module Admin
    module Sellers
      class PricesImportsController < Spree::Admin::BaseController
        include Spree::Core::ControllerHelpers::Pricing

        def create
          csv_path = params["prices"].path
          importer = SolidusPaypalMarketplace::Importer::Price.new(
            currency: current_pricing_options.currency,
            file: csv_path,
            prices_scope: model_class.accessible_by(current_ability)
          )
          import = importer.import

          info = I18n.t('solidus_paypal_marketplace.offer_importer.result')

          if import.errors.any?
            flash[:notice] = info + I18n.t(
              'solidus_paypal_marketplace.offer_importer.result_with_error', errors: import.errors.join(', ')
            )
          else
            flash[:success] = info
          end

          redirect_to spree.admin_sellers_prices_path
        end

        private

        def model_class
          Spree::Price
        end
      end
    end
  end
end
