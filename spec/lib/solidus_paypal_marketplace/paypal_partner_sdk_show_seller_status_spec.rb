# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::PaypalPartnerSdk do
  describe '#show_seller_status', :vcr do
    subject(:show_seller_status) { described_class.show_seller_status(merchant_id: merchant_id) }

    let(:merchant_id) { ENV.fetch('DEFAULT_MERCHANT_ID_IN_PAYPAL') }

    it do
      expect(show_seller_status["merchant_id"]).to eq(merchant_id)
    end

    it do
      expect(show_seller_status["payments_receivable"]).to eq(true)
    end
  end
end
