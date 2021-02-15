# frozen_string_literal: true

class CreateSpreeSeller < ActiveRecord::Migration[6.1]
  def change
    create_table :spree_sellers do |t|
      t.string :name
      t.integer :status, null: false, default: 0
      t.integer :risk_status
      t.string :merchant_id
      t.string :merchant_id_in_paypal
      t.string :action_url
      t.float :percentage
      t.datetime :deleted_at

      t.timestamps null: false
    end
  end
end
