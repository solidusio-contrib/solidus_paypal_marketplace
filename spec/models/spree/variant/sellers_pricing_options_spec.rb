# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Variant::SellersPricingOptions, type: :model do
  describe ".from_line_item" do
    subject(:sellers_pricing_options) { described_class.from_line_item(line_item) }

    let(:line_item) { build_stubbed(:line_item, seller: seller) }
    let(:seller) { create(:seller) }

    it "returns the order's currency" do
      expect(sellers_pricing_options.desired_attributes[:currency]).to eq("USD")
    end

    it "takes the orders tax address country" do
      expect(sellers_pricing_options.desired_attributes[:country_iso]).to eq("US")
    end

    it "returns line_item's seller_id" do
      expect(sellers_pricing_options.desired_attributes[:seller_id]).to eq(seller.id)
    end

    # rubocop:disable RSpec/MessageSpies
    context 'when order has no currency' do
      it "returns the configured default currency" do
        expect(line_item.order).to receive(:currency).at_least(:once).and_return(nil)
        expect(Spree::Config).to receive(:currency).at_least(:once).and_return("RUB")
        expect(sellers_pricing_options.desired_attributes[:currency]).to eq("RUB")
      end
    end

    context "when line item has no order" do
      it "returns the configured default currency" do
        expect(line_item).to receive(:order).at_least(:once).and_return(nil)
        expect(Spree::Config).to receive(:currency).at_least(:once).and_return("RUB")
        expect(sellers_pricing_options.desired_attributes[:currency]).to eq("RUB")
      end
    end
    # rubocop:enable RSpec/MessageSpies
  end
end
