# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PreventSellersStockLocationDestructionDecorator, type: :model do
  describe '#destroy' do
    context 'when belongs to a seller' do
      let(:stock_location) { Spree::Seller.create!(name: 'Mr Good', percentage: 10.0).stock_location }

      it 'cannot be deleted' do
        expect(stock_location.destroy).to be false
      end

      it 'populate errors on destroy' do
        stock_location.destroy
        expect(
          stock_location.errors
                        .added?(:base, :cannot_destroy_sellers_stock_location)
        ).to be true
      end
    end
  end
end
