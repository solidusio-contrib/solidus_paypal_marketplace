# frozen_string_literal: true

require 'spec_helper'

describe 'Seller Dashboard', type: :feature do
  include Warden::Test::Helpers

  context 'when logged as seller user' do
    let(:user) { create(:seller_user, seller: seller) }

    before do
      login_as user
    end

    context 'when the seller is in pending' do
      let(:seller) { create(:seller, action_url: 'https://example.com/onboarding') }

      it 'shows the button to link the PayPal account' do
        visit spree.admin_sellers_dashboard_path
        expect(page).to have_link(I18n.t('spree.seller.link_paypal_account'))
        expect(page).not_to have_link(I18n.t('spree.admin.tab.offers'))
      end
    end

    context 'when the seller is accepted' do
      let(:seller) { create(:accepted_seller) }

      it 'shows the accepted message' do
        visit spree.admin_sellers_dashboard_path
        expect(page).to have_content('Accepted')
        expect(page).to have_link(I18n.t('spree.admin.tab.offers'))
      end
    end
  end
end
