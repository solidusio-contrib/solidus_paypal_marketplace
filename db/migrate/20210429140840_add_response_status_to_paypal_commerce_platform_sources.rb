class AddResponseStatusToPaypalCommercePlatformSources < ActiveRecord::Migration[6.1]
  def change
    add_column :paypal_commerce_platform_sources, :response_status, :integer
  end
end
