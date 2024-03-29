# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Sellers::ShipmentManagement::Accept do
  subject(:do_accept) { described_class.call(shipment) }

  let(:line_item) { create(:line_item) }
  let(:order) { create(:completed_order_with_pending_payment, line_items: [line_item]) }
  let(:payments) { order.payments }
  let(:shipment) { order.shipments.first }

  it do
    expect(described_class).to respond_to(:call).with_unlimited_arguments
  end

  it do
    expect(described_class.new).to respond_to(:call).with(1).arguments
  end

  describe '#call' do
    it 'returns true' do
      expect(do_accept).to be true
    end

    it 'captures all order payments' do
      expect { do_accept }.to change{ payments.pluck(:state).uniq }.from(['pending']).to(['completed'])
    end

    context 'when payment cannot transition' do
      it 'returns false' do
        allow(payments.first).to receive(:can_complete?).and_return(false)
        expect(do_accept).to be false
      end
    end
  end
end
