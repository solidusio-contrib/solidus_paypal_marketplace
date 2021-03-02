# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AddSellerToPriceDecorator, type: :model do
  let(:described_class) { Spree::Price }

  it do
    expect(described_class.new)
      .to belong_to(:seller)
      .class_name('Spree::Seller')
      .optional
  end
end
