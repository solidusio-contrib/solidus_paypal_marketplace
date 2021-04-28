# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::PaypalPartnerSdk do
  describe '#execute', vcr: { tag: :paypal_api } do
    subject(:execute) { described_class.execute(OpenStruct.new) }

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
        expect(execute).to be_nil

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
