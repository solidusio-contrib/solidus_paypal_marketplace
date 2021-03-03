# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Seller, type: :model do
  it { is_expected.to be_kind_of Spree::SoftDeletable }
  it { is_expected.to define_enum_for(:status).with_values(pending: 0, accepted: 1, rejected: 2) }
  it { is_expected.to have_many(:users).dependent(:destroy) }
  it { is_expected.to have_many(:prices).dependent(:destroy) }
  it { is_expected.to have_one(:stock_location).dependent(:destroy) }
  it { is_expected.to have_many(:stock_items).through(:stock_location) }

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
    subject(:seller) { described_class.create!(name: 'Mr Good', percentage: 10.0) }

    it 'assign merchant_id' do
      expect(seller.merchant_id).to be_present
    end

    it 'creates default stock location' do
      expect(seller.stock_location).to be_persisted
    end
  end

  describe '#percentage' do
    subject(:seller) { described_class.new(name: 'Mr Good', percentage: 10.0) }

    it {
      expect(seller).to validate_presence_of(:percentage)
    }

    it {
      expect(seller).to validate_numericality_of(:percentage).is_greater_than_or_equal_to(0)
    }

    it {
      expect(seller).to validate_numericality_of(:percentage).is_less_than_or_equal_to(100)
    }
  end
end
