# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Seller, type: :model do
  it { is_expected.to be_kind_of Spree::SoftDeletable }
  it { is_expected.to define_enum_for(:status).with_values(pending: 0, accepted: 1, rejected: 2) }

  it do
    expect(described_class.new).to define_enum_for(:risk_status).with_values(
      subscribed: 0,
      subscribed_with_limit: 1,
      declined: 2,
      manual_review: 3,
      need_more_data: 4
    )
  end

  describe '#create' do
    subject(:seller) { described_class.create!(name: 'Mr Good') }

    it 'assign merchant_id' do
      expect(seller.merchant_id).to be_present
    end
  end

  describe '#percentage' do
    it {
      is_expected.to validate_numericality_of(:percentage).is_greater_than_or_equal_to(0)
    }
    it {
      is_expected.to validate_numericality_of(:percentage).is_less_than_or_equal_to(100)
    }
  end
end
