# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Webhooks::Handlers::MerchantPartnerConsentRevoked do
  subject(:handler) { described_class.new(params) }

  let(:params) { { resource: { merchant_id: seller.merchant_id } } }
  let(:seller) { create(:seller) }

  it do
    expect(handler).to respond_to(:call).with(0).arguments
  end

  it do
    expect(handler.call).to eq(true)
  end

  it do
    expect { handler.call }.to change { seller.reload.status }.from('accepted').to('revoked')
  end
end
