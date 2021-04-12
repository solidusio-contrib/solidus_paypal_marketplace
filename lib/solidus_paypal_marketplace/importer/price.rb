# frozen_string_literal: true

require 'csv'

module SolidusPaypalMarketplace
  module Importer
    class Price
      attr_reader :errors, :prices

      def initialize(currency:, file:, prices_scope:)
        @currency = currency
        @prices_scope = prices_scope
        io = File.read(file)
        @csv_rows = CSV.parse(io, headers: true)
        raise StandardError, 'uncompliant csv format' unless csv_compliant?

        @errors = []
        @prices = parse_csv_rows.compact
      end

      def import
        @prices.each do |price|
          @errors.concat(price.errors.full_messages) unless price.save
        end
        self
      end

      private

      def find_or_initialize_variant_price(variant)
        @prices_scope.find_or_initialize_by(
          country: nil,
          variant: variant
        )
      end

      def label_for(attribute)
        Spree::Price.human_attribute_name(attribute)
      end

      def parse_csv_rows
        @csv_rows.map do |row|
          sku = row[label_for(:sku)]
          variant = Spree::Variant.find_by(sku: sku)
          if variant.blank?
            @errors << "#{sku} is not a valid #{label_for(:sku)}"
            next nil
          end
          if row.to_h.values.any?(&:blank?)
            @errors << "#{sku}: row values must all be filled"
            next nil
          end
          find_or_initialize_variant_price(variant).tap do |price|
            price.amount = row[label_for(:amount)]
            price.seller_stock_availability = row[label_for(:seller_stock_availability)]
          end
        end
      end

      def csv_compliant?
        @csv_rows.headers == [:sku, :amount, :seller_stock_availability].map { |key| label_for(key) }
      end
    end
  end
end
