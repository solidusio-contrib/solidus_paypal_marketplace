# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::PaypalPartnerSdk do
  describe '#show_seller_status', vcr: { tag: :paypal_api, match_requests_on: [:method, :generic_partner_referral] } do
    subject(:show_seller_status) { described_class.show_seller_status(merchant_id: merchant_id) }

    let(:merchant_id) { ENV.fetch('DEFAULT_MERCHANT_ID_IN_PAYPAL', 'merchant-id') }

    it do
      expect(show_seller_status["payments_receivable"]).to eq(true)
    end
  end
end
