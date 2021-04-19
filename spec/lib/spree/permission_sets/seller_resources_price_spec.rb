# frozen_string_literal: true

require 'spec_helper'
require 'cancan/matchers'

RSpec.describe Spree::PermissionSets::SellerResources do
  subject(:ability) { Spree::Ability.new(user) }

  let(:price) { create(:price) }

  context 'when is a seller' do
    let(:seller) { create(:seller) }
    let(:seller_price) { create(:price, seller: seller) }
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
      expect(ability).to be_able_to([:create, :update, :destroy], seller_price)
    end

    context 'when is rejected' do
      it 'cannot manage his price' do
        seller.update!(status: :rejected)
        expect(ability).not_to be_able_to([:create, :update, :destroy], seller_price)
      end
    end

    context 'when is revoked' do
      it 'cannot manage his price' do
        seller.update!(status: :revoked)
        expect(ability).not_to be_able_to([:create, :update, :destroy], seller_price)
      end
    end
  end
end
