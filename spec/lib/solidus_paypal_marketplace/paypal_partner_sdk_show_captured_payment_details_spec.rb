# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::PaypalPartnerSdk do
  describe '#show_captured_payment_details', vcr: {
    tag: :paypal_api, match_requests_on: [:method, :generic_capture]
  } do
    subject(:show_captured_payment_details) { described_class.show_captured_payment_details(capture_id: capture_id) }

    let(:capture_id) { 'capture-id' }

    it do
      expect(show_captured_payment_details.status).to eq('COMPLETED')
    end
  end
end
