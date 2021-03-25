# frozen_string_literal: true

module Spree
  class Variant
    class SellersPricingOptions < Spree::Variant::PricingOptions
      def self.from_line_item(line_item)
        tax_address = line_item.order&.tax_address
        new(
          currency: line_item.currency || Spree::Config.currency,
          country_iso: tax_address && tax_address.country&.iso,
          seller_id: line_item.seller_id
        )
      end
    end
  end
end
