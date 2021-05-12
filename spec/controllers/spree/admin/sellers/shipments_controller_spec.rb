# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::Sellers::ShipmentsController, type: :controller do
  include Devise::Test::ControllerHelpers
  let(:shipment) { order.shipments.first }
  let(:order) { create(:completed_order_with_pending_payment, line_items: [line_item]) }
  let(:line_item) { create(:line_item) }
  let(:seller) { line_item.seller }

  before do
    user = create(:seller_user, seller: seller)
    sign_in(user)
    shipment.update!(stock_location: seller.stock_location)
  end

  describe '#index' do
    it 'renders' do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#edit' do
    it 'renders' do
      get :edit, params: { id: shipment.number }
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#accept' do
    it 'redirects' do
      get :accept, params: { id: shipment.number }
      expect(response).to redirect_to(spree.edit_admin_sellers_shipment_path(shipment))
    end

    it 'calls accept' do
      interactor = SolidusPaypalMarketplace::Sellers::ShipmentManagement::Accept
      allow(interactor).to receive(:call).and_return(true)
      get :accept, params: { id: shipment.number }
      expect(interactor).to have_received(:call).with(shipment)
    end
  end

  describe '#reject' do
    it 'redirects' do
      get :reject, params: { id: shipment.number }
      expect(response).to redirect_to(spree.edit_admin_sellers_shipment_path(shipment))
    end

    it 'calls reject' do
      seller.update(merchant_id_in_paypal: 'merchant-id-in-paypal')
      interactor = SolidusPaypalMarketplace::Sellers::ShipmentManagement::Reject
      allow(interactor).to receive(:call).and_return(true)
      get :reject, params: { id: shipment.number }
      expect(interactor).to have_received(:call).with(shipment, merchant_id_in_paypal: 'merchant-id-in-paypal')
    end
  end

  describe '#ship' do
    it 'redirects' do
      get :reject, params: { id: shipment.number }
      expect(response).to redirect_to(spree.edit_admin_sellers_shipment_path(shipment))
    end

    it 'calls ship' do
      interactor = SolidusPaypalMarketplace::Sellers::ShipmentManagement::Ship
      allow(interactor).to receive(:call).and_return(true)
      get :ship, params: { id: shipment.number }
      expect(interactor).to have_received(:call).with(shipment)
    end
  end
end
