# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Webhooks::Handlers::PaymentCaptureCompleted do
  subject(:handler) { described_class.new(context) }

  let(:context) { OpenStruct.new(params: params) }
  let(:params) { { resource: { "id" => payment_source.capture_id } } }
  let(:payment) do
    create(:payment, order: create(:order_ready_to_ship),
                     payment_method: payment_method,
                     source: payment_source,
                     state: 'completed')
  end
  let(:payment_method) { create(:paypal_payment_method) }
  let(:payment_source) do
    SolidusPaypalCommercePlatform::PaymentSource.create!(
      capture_id: 'capture-id',
      payment_method: payment_method,
      paypal_order_id: 'paypal-order-id',
      response_status: 'pending'
    )
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
      expect { handler.call }.to change { payment_source.reload.response_status }.from('pending').to('completed')
    end

    it do
      expect { handler.call }.not_to change { payment.reload.state }.from('completed')
    end

    context 'when the update fails' do
      let(:errors) { OpenStruct.new(full_messages: ["generic error"]) }

      before do
        allow(Spree::PaymentSource).to receive(:find_by).with(capture_id: payment_source.capture_id)
                                                        .and_return(payment_source)
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
