# frozen_string_literal: true

require 'spec_helper'

describe 'Sellers Offers', type: :feature do
  include Warden::Test::Helpers

  context 'when logged as admin user' do
    let(:seller) { create(:pending_seller) }
    let(:admin) { create(:admin) }
    let(:user) { create(:admin_user) }

    before do
      login_as user
    end

    describe 'start the seller onboarding', vcr: { tag: :paypal_api } do
      it 'update the action_url on the seller' do
        visit spree.edit_admin_seller_path(seller)
        expect(page).to have_link(I18n.t('spree.seller.start_onboarding'))

        expect(seller.action_url).to be_nil
        click_on(I18n.t('spree.seller.start_onboarding'))
        expect(page).to have_content(I18n.t('spree.seller.start_onboarding_successfully'))

        expect(seller.reload.action_url).not_to be_nil
      end
    end
  end
end
