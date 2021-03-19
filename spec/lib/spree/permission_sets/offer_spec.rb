# frozen_string_literal: true

require 'spec_helper'
require 'cancan/matchers'

RSpec.describe Spree::PermissionSets::Offer do
  subject(:ability) { Spree::Ability.new(user) }

  let(:price) { create(:price) }
  let(:user) { nil }

  context 'when is a seller' do
    let(:seller) { create(:seller) }
    let(:user){ create(:seller_user, seller: seller ) }

    it 'cannot manage base price' do
      expect(ability).not_to be_able_to([:create, :update, :destroy], price)
    end

    it 'cannot manage other seller\'s price' do
      seller = create(:seller, name: 'Other Seller')
      price.update!(seller_id: seller.id)
      expect(ability).not_to be_able_to([:create, :update, :destroy], price)
    end

    it 'can manage his price' do
      price.update!(seller_id: seller.id)
      expect(ability).to be_able_to([:create, :update, :destroy], price)
    end
  end
end
