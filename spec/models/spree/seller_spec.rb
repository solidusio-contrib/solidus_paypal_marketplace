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

  describe '#set_merchant_id' do
    context 'before create assign merchant_id' do
      it do
        instance = described_class.create!(name: 'Mr Good')
        expect(instance.merchant_id).to be_present
      end
    end
  end
end
