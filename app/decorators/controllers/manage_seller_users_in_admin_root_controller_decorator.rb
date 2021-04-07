# frozen_string_literal: true

module ManageSellerUsersInAdminRootControllerDecorator
  def index
    if current_spree_user&.has_spree_role?(:seller)
      redirect_to admin_sellers_dashboard_path
    else
      super
    end
  end

  Spree::Admin::RootController.prepend(self)
end
