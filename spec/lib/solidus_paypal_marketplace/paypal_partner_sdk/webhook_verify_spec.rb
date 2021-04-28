# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::PaypalPartnerSdk::WebhookVerify do
  subject(:verify) { described_class.new(headers: headers, params: params) }

  let(:headers) {
    {
      "PAYPAL-AUTH-ALGO" => "string",
      "PAYPAL-CERT-URL" => "string",
      "PAYPAL-TRANSMISSION-ID" => "string",
      "PAYPAL-TRANSMISSION-SIG" => "string",
      "PAYPAL-TRANSMISSION-TIME" => "string"
    }
  }
  let(:params) {
    { something: "string" }
  }

  before do
    SolidusPaypalMarketplace.config.paypal_webhook_id = "string"
  end

  it { is_expected.to respond_to(:path) }
  it { is_expected.to respond_to(:verb) }
  it { is_expected.to respond_to(:headers) }
  it { is_expected.to respond_to(:body) }

  describe "#path" do
    it do
      expect(verify.path).to eq '/v1/notifications/verify-webhook-signature'
    end
  end

  describe "#verb" do
    it do
      expect(verify.verb).to eq 'POST'
    end
  end

  describe "#headers" do
    it do
      expect(verify.headers['Content-Type']).to eq 'application/json'
    end
  end

  describe "#body" do
    [
      "auth_algo",
      "cert_url",
      "transmission_id",
      "transmission_sig",
      "transmission_time",
      "webhook_id",
      "webhook_event"
    ].each do |key|
      it "includes #{key}" do
        expect(verify.body[key]).to be_present
      end
    end
  end
end
