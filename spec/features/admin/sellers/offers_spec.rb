# frozen_string_literal: true

require 'spec_helper'

describe 'Sellers Offers', type: :feature do
  include Warden::Test::Helpers

  context 'when logged as seller user' do
    let(:seller) { create(:accepted_seller) }
    let(:user) { create(:seller_user, seller: seller) }

    before do
      login_as user
    end

    describe 'seller\s offers page' do
      it 'can create a new offer' do
        visit spree.admin_sellers_prices_path
        expect(page).to have_link('New Offer')
      end
    end

    describe 'creating a new offer' do
      it 'can save it' do
        variant = create(:variant)
        visit spree.new_admin_sellers_price_path
        fill_in 'Price', with: 100
        select variant.descriptive_name
        click_button('Create')
        expect(page).to have_content('Offer has been successfully created!')
      end
    end

    describe 'editing a offer' do
      it 'can save it' do
        variant = create(:variant)
        price = create(:price, amount: 10, seller_id: seller.id, variant_id: variant.id)
        visit spree.edit_admin_sellers_price_path(price)
        fill_in 'Price', with: 100
        click_button('Update')
        expect(page).to have_content('Offer has been successfully updated!')
      end
    end
  end
end
