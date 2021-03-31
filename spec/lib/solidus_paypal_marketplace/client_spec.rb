require 'spec_helper'
require 'net/http'

RSpec.describe SolidusPaypalMarketplace::Client do
  subject(:client) { described_class.new(client_id: "1234", partner_code: 'PCP_CODE') }

  describe '#execute_with_response' do
    let(:request_class) { SolidusPaypalCommercePlatform::Gateway::OrdersCaptureRequest }
    let(:paypal_request) { double(:request, class: request_class) } # rubocop:disable RSpec/VerifiedDoubles
    let(:paypal_response) { double(:response, status_code: status_code, result: nil, headers: {}) } # rubocop:disable RSpec/VerifiedDoubles
    let(:status_code) { 201 }
    let(:environment) { PayPal::SandboxEnvironment.new('1234', 'secret') }
    let(:req) { OpenStruct.new(verb: 'POST', path: '/v1/oauth2/token') }

    it 'adds the partner_code to the headers', :webmock, :vcr_off do
      stub_request(:post, "https://api.sandbox.paypal.com/v1/oauth2/token")
      # stub_request(:any, environment.base_url)

      client.execute(req)

      assert_requested :post, "#{environment.base_url}/v1/oauth2/token", {
        headers: { 'PayPal-Partner-Attribution-Id' => 'PCP_CODE' },
        times: 1
      }
    end

    it 'forwards to the upstream client adding i18n response messages' do
      allow_any_instance_of(PayPal::PayPalHttpClient) # rubocop:disable RSpec/AnyInstance
        .to receive(:execute).with(paypal_request).and_return(paypal_response)

      response = client.execute_with_response(paypal_request)

      expect(response.message).to eq("Payment captured")
    end
  end
end
