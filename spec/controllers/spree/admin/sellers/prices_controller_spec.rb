# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::Sellers::PricesController, type: :controller do
  include Devise::Test::ControllerHelpers
  let(:seller) { create(:seller) }
  let(:variant) { create(:variant) }

  before do
    user = create(:seller_user, seller: seller)
    sign_in(user)
  end

  describe '#index' do
    it 'renders' do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#new' do
    it 'renders' do
      get :new
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#create' do
    it 'redirects' do
      post :create, params: { price: {
        variant_id: variant.id.to_s,
        country_iso: '',
        amount: '10',
        currency: 'USD',
        seller_stock_availability: '0'
      } }
      expect(response).to redirect_to(spree.admin_sellers_prices_path)
    end
  end

  describe '#edit' do
    it 'responds' do
      get :new
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#update' do
    it 'redirects' do
      price = create(:price, seller: seller, variant: variant)
      put :update, params: { id: price.id, price: {
        variant_id: variant.id.to_s,
        seller_stock_availability: '20'
      } }
      expect(response).to redirect_to(spree.admin_sellers_prices_path)
    end
  end
end
