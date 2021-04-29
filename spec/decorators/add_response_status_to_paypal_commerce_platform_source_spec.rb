# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AddResponseStatusToPaypalCommercePlatformSource, type: :model do
  let(:described_class) { SolidusPaypalCommercePlatform::PaymentSource }

  it do
    expect(described_class.new).to define_enum_for(:response_status).with_values(
      completed: 0,
      declined: 1,
      partially_refunded: 2,
      pending: 3,
      refunded: 4
    )
  end
end
