# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Webhooks::Handlers::PaymentCaptureDenied do
  subject(:handler) { described_class.new(context) }

  let(:context) { OpenStruct.new(params: params) }
  let(:params) { { resource: { "id" => payment.id } } }
  let(:payment) do
    create(:payment, order: create(:order_ready_to_ship),
                     payment_method: payment_method,
                     source: payment_source)
  end
  let(:payment_method) { create(:paypal_payment_method) }
  let(:payment_source) do
    SolidusPaypalCommercePlatform::PaymentSource.create!(
      payment_method: payment_method,
      paypal_order_id: 'paypal-order-id',
      response_status: 'pending'
    )
  end
  let(:shipment) { payment.order.shipments.first }

  before do
    payment.started_processing!
    shipment.pend!
  end

  describe '#call' do
    it do
      expect(handler).to respond_to(:call).with(0).arguments
    end

    it do
      expect(handler.call).to be_present
    end

    it do
      expect(handler.call[:result]).to eq(true)
    end

    it do
      expect { handler.call }.to change { payment_source.reload.response_status }.from('pending').to('declined')
    end

    it do
      expect { handler.call }.to change { payment.reload.state }.from('processing').to('failed')
    end

    context 'when the update fails' do
      let(:errors) { OpenStruct.new(full_messages: ["generic error"]) }

      before do
        allow(Spree::Payment).to receive(:find).with(payment.id)
                                               .and_return(payment)
        allow(payment_source).to receive(:update).and_return(false)
        allow(payment_source).to receive(:errors).and_return(errors)
      end

      it do
        expect(handler.call[:result]).to eq(false)
      end

      it do
        expect(handler.call[:errors]).to eq(errors.full_messages)
      end
    end
  end
end
