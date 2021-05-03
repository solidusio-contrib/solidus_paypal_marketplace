# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Webhooks::Handlers::MerchantPartnerConsentRevoked do
  subject(:handler) { described_class.new(context) }

  let(:context) { OpenStruct.new(params: params) }
  let(:params) { { resource: { "merchant_id" => seller.merchant_id_in_paypal } } }
  let(:seller) { create(:seller, merchant_id_in_paypal: 'merchant-id') }

  it do
    expect(handler).to respond_to(:call).with(0).arguments
  end

  it do
    expect(handler.call).to be_present
  end

  it do
    expect(handler.call[:result]).to eq(true)
  end

  it do
    expect { handler.call }.to change { seller.reload.status }.from('accepted').to('revoked')
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
