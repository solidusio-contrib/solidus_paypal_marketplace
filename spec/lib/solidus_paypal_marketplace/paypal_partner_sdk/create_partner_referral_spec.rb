# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::PaypalPartnerSdk::CreatePartnerReferral do
  describe '#body' do
    subject(:body) { described_class.new.body }

    it "doesn't contain the tracking key" do
      expect(body).not_to match hash_including('tracking_id')
    end

    context 'when tracking_id is provided' do
      subject(:body) { described_class.new(tracking_id: 'ABC').body }

      it "contains the tracking key" do
        expect(body).to match hash_including('tracking_id': 'ABC')
      end
    end

    context 'when return_url is provided' do
      subject(:body) { described_class.new(return_url: 'ABC').body }

      it "contains the return_url" do
        expect(body[:partner_config_override]).to match hash_including('return_url': 'ABC')
      end
    end
  end
end
