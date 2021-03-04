class RemoveSpreeOffer < ActiveRecord::Migration[6.1]
  def change
    drop_table :spree_offers do |t|
      t.references :variant, null: false, index: true
      t.string :internal_seller_sku
      t.datetime :deleted_at

      t.timestamps null: false
    end
  end
end
