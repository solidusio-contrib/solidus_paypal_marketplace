# frozen_string_literal: true

module Spree
  module Admin
    module Sellers
      class ResourceController < Spree::Admin::ResourceController
        before_action :complete_paypal_onboarding, unless: -> { current_spree_user.seller.accepted? }

        private

        def complete_paypal_onboarding
          flash[:error] = I18n.t('spree.seller.paypal_account_not_connected')

          redirect_to admin_sellers_dashboard_path
        end

        def new_object_url(options = {})
          if parent?
            spree.new_polymorphic_url([:admin, :sellers, parent, model_class], options)
          else
            spree.new_polymorphic_url([:admin, :sellers, model_class], options)
          end
        end

        def edit_object_url(object, options = {})
          if parent?
            spree.polymorphic_url([:edit, :admin, :sellers, parent, object], options)
          else
            spree.polymorphic_url([:edit, :admin, :sellers, object], options)
          end
        end

        def object_url(object = nil, options = {})
          target = object || @object

          if parent?
            spree.polymorphic_url([:admin, :sellers, parent, target], options)
          else
            spree.polymorphic_url([:admin, :sellers, target], options)
          end
        end

        def collection_url(options = {})
          if parent?
            spree.polymorphic_url([:admin, :sellers, parent, model_class], options)
          else
            spree.polymorphic_url([:admin, :sellers, model_class], options)
          end
        end
      end
    end
  end
end
