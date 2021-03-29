# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Sellers::ShipmentManagement::Ship do
  subject(:do_ship) { described_class.call(shipment) }

  let(:line_item) { create(:line_item) }
  let(:order) { create(:order_ready_to_ship, line_items: [line_item]) }
  let(:shipment) { order.shipments.first }

  it do
    expect(described_class).to respond_to(:call).with_unlimited_arguments
  end

  it do
    expect(described_class.new).to respond_to(:call).with(1).arguments
  end

  describe '#call' do
    it 'returns true' do
      expect(do_ship).to be true
    end

    it 'sets shipment status to shipped' do
      expect { do_ship }.to change(shipment, :state).from('ready').to('shipped')
    end

    context 'when shipment cannot transition' do
      before do
        shipment.update!(state: :pending)
      end

      it 'returns false' do
        expect(do_ship).to be false
      end
    end
  end
end
