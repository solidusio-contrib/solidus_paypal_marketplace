# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AddPaypalChecksToPaymentDecorator, type: :model do
  subject(:payment) { described_class.new(source: source) }

  let(:described_class) { Spree::Payment }
  let(:source) { nil }

  it { is_expected.to respond_to(:paypal_pending?) }

  it do
    expect(payment.paypal_pending?).to be(false)
  end

  context 'when payment_method has marketplace payment method ' do
    let(:source) { SolidusPaypalCommercePlatform::PaymentSource.new }

    it 'checks if source response status is pending' do
      allow(source).to receive(:pending?)
      payment.paypal_pending?
      expect(source).to have_received(:pending?)
    end

    it 'returns true if source is pending' do
      source.response_status = 'pending'
      expect(payment.paypal_pending?).to be(true)
    end

    it 'returns false if source is not pending' do
      source.response_status = nil
      expect(payment.paypal_pending?).to be(false)
    end
  end
end
