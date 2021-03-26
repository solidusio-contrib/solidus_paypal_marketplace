# frozen_string_literal: true

require 'spec_helper'

describe 'checkout delivery page', type: :feature do
  include Warden::Test::Helpers

  let(:order) do
    Spree::TestingSupport::MarketplaceOrderWalkthrough.up_to(:address, order: line_item.order, line_item: line_item)
  end
  let(:seller) { create(:seller) }
  let(:price) { create(:price, amount: 123.90, seller: seller) }
  let(:line_item) { create(:line_item, variant: price.variant, seller: seller) }
  let(:lowest_price) { create(:price, variant: price.variant, amount: 12.90, seller: create(:seller)) }

  before do
    create(:stock_location)

    order.reload
    lowest_price

    user = create(:user)
    order.user = user
    login_as user

    order.recalculate
  end

  it 'displays the selected price instead of the lowest price' do
    visit spree.checkout_state_path(:delivery, order: order)
    expect(page).to have_content('123.90')

    click_button "Save and Continue"
  end
end
