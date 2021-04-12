# frozen_string_literal: true

CSV.generate do |csv|
  csv << [
    Spree::Price.human_attribute_name(:sku),
    Spree::Price.human_attribute_name(:amount),
    Spree::Price.human_attribute_name(:seller_stock_availability)
  ]
  @collection.each do |price|
    csv << [
      price.variant.sku,
      price.amount,
      price.seller_stock_availability
    ]
  end
end
