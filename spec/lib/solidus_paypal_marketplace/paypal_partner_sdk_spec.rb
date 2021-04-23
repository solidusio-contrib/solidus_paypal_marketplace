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

    context 'when PayPal returns an error' do
      let(:paypal_client) { instance_double(PayPal::PayPalHttpClient) }
      let(:paypal_http_error) do
        PayPalHttp::HttpError.new(
          'status_code',
          OpenStruct.new(error: 'invalid_client', error_description: 'Client Authentication failed'),
          'paypal-debug-id' => 'paypal-debug-id'
        )
      end
      let(:rails_logger) { instance_double(ActiveSupport::Logger, error: nil) }

      before do
        allow(SolidusPaypalMarketplace).to receive(:client).and_return(paypal_client)
        allow(paypal_client).to receive(:execute).and_raise(paypal_http_error)

        allow(Rails).to receive(:logger).and_return(rails_logger)
      end

      it 'returns nil and logs the errors' do
        expect(generate_paypal_sign_up_link).to be_nil

        expect(rails_logger).to have_received(:error).with('status_code')
        expect(rails_logger).to have_received(:error).with({ "paypal-debug-id" => "paypal-debug-id" })
        expect(rails_logger).to have_received(:error).with(
          OpenStruct.new(
            error: "invalid_client", error_description: "Client Authentication failed"
          )
        )
      end
    end
  end
end
