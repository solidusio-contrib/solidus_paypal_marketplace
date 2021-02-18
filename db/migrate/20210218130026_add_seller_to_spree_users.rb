# frozen_string_literal: true

class AddSellerToSpreeUsers < ActiveRecord::Migration[6.1]
  def change
    add_reference :spree_users, :seller, index: true
  end
end
