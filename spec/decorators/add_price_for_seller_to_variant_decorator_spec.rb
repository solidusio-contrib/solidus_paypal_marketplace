# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AddPriceForSellerToVariantDecorator, type: :model do
  let(:described_class) { Spree::Variant }

  it do
    expect(described_class.new).to delegate_method(:price_for_seller).to :price_selector
  end
end
