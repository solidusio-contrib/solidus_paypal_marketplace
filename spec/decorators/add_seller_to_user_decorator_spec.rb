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

  it do
    expect(described_class.new).not_to validate_presence_of(:seller)
  end

  context 'when has seller role' do
    subject(:seller_user) { described_class.new(spree_roles: [seller_role]) }

    let(:seller_role) { create(:role, name: 'seller') }

    it do
      expect(seller_user).to validate_presence_of(:seller)
    end
  end
end
