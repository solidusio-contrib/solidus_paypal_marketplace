# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::SellersController, type: :controller do
  stub_authorization!

  it 'index sellers' do
    get :index
    expect(response).to have_http_status(:ok)
  end

  it 'initialize seller' do
    get :new
    expect(response).to have_http_status(:ok)
  end

  it 'create seller' do
    post :create, params: { seller: { name: 'Seller' } }
    expect(response).to redirect_to(spree.admin_sellers_path)
  end
end
