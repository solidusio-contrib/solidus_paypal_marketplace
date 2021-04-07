# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ManageSellerUsersInAdminRootControllerDecorator, type: :controller do
  include Devise::Test::ControllerHelpers
  let(:user) { create(:user) }

  before do
    sign_in(user)
    @controller = Spree::Admin::RootController.new
  end

  describe '#index' do
    it 'redirects to admin root' do
      get :index
      expect(response).to be_redirect
      expect(response).not_to redirect_to('/unauthorized')
    end

    context 'when user has seller role' do
      let(:user) { create(:seller_user, seller: create(:seller)) }

      it 'redirects to seller dashboard' do
        get :index
        expect(response).to redirect_to(spree.admin_sellers_dashboard_path)
      end
    end
  end
end
