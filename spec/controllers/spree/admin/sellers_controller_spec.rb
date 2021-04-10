# frozen_string_literal: true

require 'spec_helper'

describe Spree::Admin::SellersController, type: :controller do
  stub_authorization!

  describe '#index' do
    it 'indexes sellers' do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#new' do
    it 'initializes seller' do
      get :new
      expect(response).to have_http_status(:ok)
    end
  end

  describe '#create' do
    let(:params) { { seller: { name: 'Seller', percentage: 10.0 } } }

    before do
      allow(controller).to receive(:_start_onboarding).and_return(true)
      post :create, params: params
    end

    it 'creates seller' do
      expect(response).to redirect_to(spree.admin_sellers_path)
    end

    it 'tries seller onboarding' do
      expect(controller).to have_received(:_start_onboarding)
    end

    context 'when seller is not valid' do
      let(:params) { {} }

      it 'does not try seller onboarding' do
        expect(controller).not_to have_received(:_start_onboarding)
      end
    end
  end
end
