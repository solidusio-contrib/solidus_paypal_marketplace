# frozen_string_literal: true

module Spree
  module Admin
    module Sellers
      class DashboardController < Spree::Admin::BaseController
        skip_before_action :authorize_admin

        def show
          authorize! :visit, :seller_dashboard

          @seller = current_spree_user.seller
        end
      end
    end
  end
end
