class AddSellerToStockLocations < ActiveRecord::Migration[6.1]
  def change
    add_reference :spree_stock_locations, :seller, index: true
  end
end
