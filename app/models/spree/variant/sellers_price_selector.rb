# frozen_string_literal: true

module Spree
  class Variant
    class SellersPriceSelector < Spree::Variant::PriceSelector
      def self.pricing_options_class
        Spree::Variant::SellersPricingOptions
      end

      def lowest_seller_price_for(price_options)
        prices = Spree::Seller.kept.map do |seller|
          price_for_seller(seller, price_options)
        end
        min_prices(prices)
      end

      def price_for(price_options)
        price = variant.prices.with_seller.currently_valid.detect do |variant_price|
          price_matches_desired_options?(variant_price, price_options.desired_attributes)
        end

        return price if ::Spree.solidus_gem_version >= Gem::Version.new('3.1.0.alpha')

        price&.money
      end

      def price_for_options(price_options)
        price_for(price_options)
      end

      def price_for_seller(seller, price_options)
        desired_attributes = price_options.desired_attributes.merge({ seller_id: seller.id })
        seller_price_options = Spree::Config.pricing_options_class.new(desired_attributes)
        price_for(seller_price_options)
      end

      private

      def min_prices(prices)
        return prices.compact.min_by(&:money) if ::Spree.solidus_gem_version >= Gem::Version.new('3.1.0.alpha')

        prices.compact.min
      end

      def price_matches_desired_options?(price, desired_attributes)
        price_matches_desired_country_iso?(price.country_iso, desired_attributes[:country_iso]) &&
        price_matches_desired_currency?(price.currency, desired_attributes[:currency]) &&
        price_matches_desired_seller_id?(price.seller_id, desired_attributes[:seller_id])
      end

      def price_matches_desired_country_iso?(price_country_iso, desired_country_iso)
        price_country_iso == desired_country_iso || price_country_iso.nil?
      end

      def price_matches_desired_currency?(price_currency, desired_currency)
        price_currency == desired_currency
      end

      def price_matches_desired_seller_id?(price_seller_id, desired_seller_id)
        price_seller_id == desired_seller_id || desired_seller_id.nil?
      end
    end
  end
end
