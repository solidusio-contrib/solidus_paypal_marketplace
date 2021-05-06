# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Sellers::Captures::StatusRefresh do
  subject(:status_refresh) { described_class.call(capture_id) }

  let(:capture_id) { 'capture-id' }
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

  it do
    expect(described_class).to respond_to(:call).with_unlimited_arguments
  end

  it do
    expect(described_class).to respond_to(:new).with(0).arguments
  end

  it do
    expect(described_class.new).to respond_to(:call).with(1).arguments
  end

  describe '#call' do
    let(:response) do
      OpenStruct.new(status: status)
    end

    before do
      allow(SolidusPaypalCommercePlatform::PaymentSource).to(
        receive(:find_by).with(capture_id: capture_id)
        .and_return(payment_source)
      )
      allow(SolidusPaypalMarketplace::PaypalPartnerSdk).to(
        receive(:show_captured_payment_details).with(capture_id: capture_id)
        .and_return(response)
      )
    end

    context 'when capture status is completed' do
      let(:status) { 'COMPLETED' }

      it do
        expect(status_refresh).to be(true)
      end

      it do
        expect { status_refresh }.to change(payment_source, :response_status).from('pending').to('completed')
      end

      it do
        expect { status_refresh }.not_to change { payment.reload.state }.from('completed')
      end
    end

    context 'when capture status is denied' do
      let(:status) { 'DECLINED' }

      it do
        expect(status_refresh).to be(true)
      end

      it do
        expect { status_refresh }.to change(payment_source, :response_status).from('pending').to('declined')
      end

      it do
        expect { status_refresh }.to change { payment.reload.state }.from('completed').to('failed')
      end
    end
  end
end
