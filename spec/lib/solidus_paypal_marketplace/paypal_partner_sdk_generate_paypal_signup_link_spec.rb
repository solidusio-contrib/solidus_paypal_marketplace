# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::PaypalPartnerSdk do
  describe '#generate_paypal_signup_link', vcr: { tag: :paypal_api } do
    subject(:generate_paypal_sign_up_link) { described_class.generate_paypal_sign_up_link }

    it 'returns a new paypal sign up link' do
      expect(generate_paypal_sign_up_link).to include 'merchantsignup/partner/onboardingentry?token='
    end

    context 'with tracking_id and return_url' do
      subject(:generate_paypal_sign_up_link) do
        described_class.generate_paypal_sign_up_link(
          tracking_id: 'ID',
          return_url: 'https://example.com/callbacks'
        )
      end

      let(:paypal_client) { instance_double(PayPal::PayPalHttpClient) }
      # rubocop:disable RSpec/VerifiedDoubles
      let(:link) { double(OpenStruct, href: 'http://example.com/sign_up_link', rel: 'action_url') }
      let(:result) { double(OpenStruct, links: [link]) }
      let(:response) { double(OpenStruct, result: result) }
      # rubocop:enable RSpec/VerifiedDoubles

      before do
        allow(SolidusPaypalMarketplace).to receive(:client).and_return(paypal_client)
        allow(paypal_client).to receive(:execute).and_return(response)
      end

      it 'returns a new paypal sign up link' do
        expect(generate_paypal_sign_up_link).to eq link.href
      end
    end
  end
end
