# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AddSellerToLineItemDecorator, type: :model do
  let(:described_class) { Spree::LineItem }

  it do
    expect(described_class.new)
      .to belong_to(:seller)
      .class_name('Spree::Seller')
  end
end
