# frozen_string_literal: true

require 'spec_helper'
require 'cancan/matchers'

RSpec.describe Spree::PermissionSets::SellerResources do
  subject(:ability) { Spree::Ability.new(user) }

  let(:shipment) { create(:shipment) }
  let(:stock_location) { shipment.stock_location }

  context 'when is a seller' do
    let(:seller) { create(:seller) }
    let(:user){ create(:seller_user, seller: seller ) }

    it 'cannot manage base shipment' do
      expect(ability).not_to be_able_to([:create, :update, :destroy], shipment)
    end

    it 'cannot manage other seller\'s shipment' do
      seller = create(:seller, name: 'Other Seller')
      stock_location.update!(seller_id: seller.id)
      expect(ability).not_to be_able_to([:create, :update, :destroy], shipment)
    end

    it 'can manage his shipment' do
      stock_location.update!(seller_id: seller.id)
      expect(ability).not_to be_able_to([:create, :update, :destroy], shipment)
    end

    context 'when order is not completed' do
      before do
        shipment.order.update!(completed_at: nil)
      end

      it 'cannot manage his shipment' do
        stock_location.update!(seller_id: seller.id)
        expect(ability).not_to be_able_to([:create, :update, :destroy], shipment)
      end
    end

    context 'without seller_id' do
      it 'cannot manage base shipment' do
        user.update!(seller_id: nil)
        expect(ability).not_to be_able_to([:create, :update, :destroy], shipment)
      end
    end

    context 'when is rejected' do
      it 'cannot manage his shipment' do
        seller.update!(status: :rejected)
        stock_location.update!(seller_id: seller.id)
        expect(ability).not_to be_able_to([:create, :update, :destroy], shipment)
      end
    end
  end
end
