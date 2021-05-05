# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Sellers::ShipmentManagement::Ready do
  subject(:do_ready) { described_class.call(shipment) }

  let(:line_item) { create(:line_item) }
  let(:order) { create(:order_ready_to_ship, line_items: [line_item]) }
  let(:shipment) { order.shipments.first }

  before do
    shipment.pend!
  end

  it do
    expect(described_class).to respond_to(:call).with_unlimited_arguments
  end

  it do
    expect(described_class.new).to respond_to(:call).with(1).arguments
  end

  describe '#call' do
    it 'returns true' do
      expect(do_ready).to be true
    end

    it 'sets shipment status to shipped' do
      expect { do_ready }.to change(shipment, :state).from('pending').to('ready')
    end

    context 'when payment are not completed' do
      before do
        order.payments.each(&:void!)
      end

      it 'returns false' do
        expect(do_ready).to be false
      end
    end

    context 'when shipment cannot transition' do
      before do
        allow(shipment).to receive(:can_ready?).and_return(false)
      end

      it 'returns false' do
        expect(do_ready).to be false
      end
    end
  end
end
