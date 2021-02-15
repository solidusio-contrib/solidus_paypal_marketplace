# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AddOfferToVariantDecorator, type: :model do
  let(:described_class) { Spree::Variant }

  it { is_expected.to have_many(:offers).class_name('Spree::Offer') }
end
