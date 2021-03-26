# frozen_string_literal: true

module AddPriceForSellerToVariantDecorator
  def self.prepended(base)
    base.delegate :lowest_seller_price_for, :price_for_seller, to: :price_selector

    class << base
      prepend ClassMethods
    end
  end

  module ClassMethods
    def with_prices(pricing_options = Spree::Config.default_pricing_options)
      where(
        Spree::Price.
          where(Spree::Variant.arel_table[:id].eq(Spree::Price.arel_table[:variant_id])).
          with_seller.
          where(
            "spree_prices.currency = ? AND (spree_prices.country_iso IS NULL OR spree_prices.country_iso = ?)",
            pricing_options.search_arguments[:currency],
            pricing_options.search_arguments[:country_iso].compact
          ).
          arel.exists
      )
    end
  end

  Spree::Variant.prepend self
end
