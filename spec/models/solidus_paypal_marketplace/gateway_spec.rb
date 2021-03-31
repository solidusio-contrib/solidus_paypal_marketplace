# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Gateway, type: :model do
  it { expect(described_class).to be < SolidusPaypalCommercePlatform::Gateway }

  describe '#new' do
    subject(:new) do
      described_class.new(
        client_id: client_id,
        client_secret: client_secret,
        test_mode: test_mode,
        partner_code: partner_code
      )
    end

    let(:client_id) { '1234' }
    let(:client_secret) { 'ABCD' }
    let(:test_mode) { 'test_mode' }
    let(:partner_code) { 'CODE' }

    before do
      allow(SolidusPaypalMarketplace::Client).to receive(:new).with(
        hash_including(:client_id, :client_secret, :test_mode, :partner_code)
      )
    end

    it 'initialize the client with the provided params' do
      new

      expect(SolidusPaypalMarketplace::Client).to have_received(:new).with(
        hash_including(
          client_id: client_id,
          client_secret: client_secret,
          test_mode: test_mode,
          partner_code: partner_code
        )
      )
    end
  end
end
