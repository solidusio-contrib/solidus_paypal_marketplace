# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Variant::PricingOptions do
  subject { described_class.new }

  context ".from_line_item" do
    let(:line_item) { build_stubbed(:line_item) }
    subject { described_class.from_line_item(line_item) }

    it "returns the order's currency" do
      expect(subject.desired_attributes[:currency]).to eq("USD")
    end

    it "takes the orders tax address country" do
      expect(subject.desired_attributes[:country_iso]).to eq("US")
    end

    context 'if order has no currency' do
      before do
        expect(line_item.order).to receive(:currency).at_least(:once).and_return(nil)
        expect(Spree::Config).to receive(:currency).at_least(:once).and_return("RUB")
      end

      it "returns the configured default currency" do
        expect(subject.desired_attributes[:currency]).to eq("RUB")
      end
    end

    context "if line item has no order" do
      before do
        expect(line_item).to receive(:order).at_least(:once).and_return(nil)
        expect(Spree::Config).to receive(:currency).at_least(:once).and_return("RUB")
      end

      it "returns the configured default currency" do
        expect(subject.desired_attributes[:currency]).to eq("RUB")
      end
    end
  end
end
