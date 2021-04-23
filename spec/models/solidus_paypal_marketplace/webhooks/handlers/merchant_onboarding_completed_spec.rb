# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Webhooks::Handlers::MerchantOnboardingCompleted do
  subject(:handler) { described_class.new(params) }

  let(:params) { { resource: { merchant_id: seller.merchant_id_in_paypal } } }
  let(:seller) { create(:pending_seller) }

  it do
    expect(handler).to respond_to(:call).with(0).arguments
  end

  describe '#call' do
    let(:response) { { "payments_receivable" => payments_receivable } }
    let(:payments_receivable) { true }

    before do
      allow(SolidusPaypalMarketplace::PaypalPartnerSdk).to receive(:show_seller_status).and_return(response)
    end

    context 'when seller\'s payments are receivable' do
      it do
        expect(handler.call).to be_present
      end

      it do
        expect(handler.call[:result]).to eq(true)
      end

      it do
        expect { handler.call }.to change { seller.reload.status }.from('pending').to('accepted')
      end
    end

    context 'when seller\'s payments are not receivable' do
      let(:payments_receivable) { false }

      it do
        expect(handler.call).to be_present
      end

      it do
        expect(handler.call[:result]).to eq(true)
      end

      it do
        expect { handler.call }.to change { seller.reload.status }.from('pending').to('require_paypal_verification')
      end
    end

    context 'when the update fail' do
      let(:errors) { OpenStruct.new(full_messages: ["generic error"]) }

      before do
        allow(Spree::Seller).to receive(:find_by).with(merchant_id_in_paypal: seller.merchant_id_in_paypal)
                                                 .and_return(seller)
        allow(seller).to receive(:update).and_return(false)
        allow(seller).to receive(:errors).and_return(errors)
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
