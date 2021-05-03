# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Webhooks::Handlers::MerchantOnboardingCompleted do
  subject(:handler) { described_class.new(context) }

  let(:context) { OpenStruct.new(admin_sellers_paypal_callbacks_url: return_url, params: params) }
  let(:merchant_id) { seller.merchant_id_in_paypal }
  let(:params) { { resource: { "merchant_id" => merchant_id } } }
  let(:seller) { create(:seller, merchant_id_in_paypal: 'merchant-id') }
  let(:return_url) { 'url' }

  it do
    expect(handler).to respond_to(:call).with(0).arguments
  end

  describe '#call' do
    let(:response) { OpenStruct.new }
    let(:status_refresh) { SolidusPaypalMarketplace::Sellers::StatusRefresh }
    let(:payments_receivable) { true }

    before do
      allow(status_refresh).to(
        receive(:call).with(seller, return_url: return_url)
                      .and_return(OpenStruct.new(seller: seller))
      )
    end

    it do
      handler.call
      expect(status_refresh).to have_received(:call)
    end

    context 'when the update succeeds' do
      before do
        allow(seller).to receive(:update).and_return(true)
      end

      it do
        expect(handler.call).to be_present
      end

      it do
        expect(handler.call[:result]).to eq(true)
      end
    end

    context 'when the update fails' do
      let(:errors) { OpenStruct.new(full_messages: ["generic error"]) }

      before do
        allow(Spree::Seller).to receive(:find_by).with(merchant_id_in_paypal: merchant_id)
                                                 .and_return(seller)
        allow(seller).to receive(:update).and_return(false)
        allow(seller).to receive(:errors).and_return(errors)
      end

      it do
        expect(handler.call).to be_present
      end

      it do
        expect(handler.call[:result]).to eq(false)
      end

      it do
        expect(handler.call[:errors]).to eq(errors.full_messages)
      end
    end
  end
end
