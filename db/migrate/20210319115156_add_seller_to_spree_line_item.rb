class AddSellerToSpreeLineItem < ActiveRecord::Migration[6.1]
  def change
    add_reference :spree_line_items, :seller, index: true
  end
end
