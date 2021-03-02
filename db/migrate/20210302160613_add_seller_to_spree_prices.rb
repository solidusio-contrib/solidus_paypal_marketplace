class AddSellerToSpreePrices < ActiveRecord::Migration[6.1]
  def change
    add_reference :spree_prices, :seller, index: true
  end
end
