# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Sellers::ShipmentManagement::Reject do
  subject(:do_reject) { described_class.call(shipment) }

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
      expect(do_reject).to be true
    end

    it 'voids all order payments' do
      expect { do_reject }.to change{ payments.pluck(:state).uniq }.from(['pending']).to(['void'])
    end

    it 'set shipment status to canceled' do
      expect { do_reject }.to change(shipment, :state).from('pending').to('canceled')
    end

    context 'when payment cannot transition' do
      it 'returns false' do
        allow(payments.first).to receive(:can_void?).and_return(false)
        expect(do_reject).to be false
      end
    end

    context 'when shipment cannot transition' do
      it 'returns false' do
        shipment.cancel!
        expect(do_reject).to be false
      end

      it 'rollbacks voids' do
        allow(shipment).to receive(:cancel!).and_raise(ActiveRecord::Rollback)
        expect { do_reject }.not_to(change{ payments.reload.pluck(:state).uniq })
      end
    end
  end
end
