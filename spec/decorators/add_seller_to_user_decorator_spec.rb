# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AddSellerToUserDecorator, type: :model do
  let(:described_class) { Spree::User }

  it do
    expect(described_class.new)
      .to belong_to(:seller)
      .class_name('Spree::Seller')
      .optional
  end
end
