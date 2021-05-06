# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::PaypalPartnerSdk::ShowCapturedPaymentDetails do
  subject(:status) { described_class.new(capture_id: capture_id) }

  let(:capture_id) { 'capture-id' }

  it { is_expected.to respond_to(:path) }
  it { is_expected.to respond_to(:verb) }
  it { is_expected.to respond_to(:headers) }
  it { is_expected.to respond_to(:body) }

  describe "#path" do
    it do
      expect(status.path).to include(capture_id)
    end
  end

  describe "#verb" do
    it do
      expect(status.verb).to eq('GET')
    end
  end

  describe "#headers" do
    it do
      expect(status.headers).to be_blank
    end
  end

  describe "#body" do
    it do
      expect(status.body).to be_blank
    end
  end
end
