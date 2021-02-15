# frozen_string_literal: true

module Spree
  class Offer < Spree::Base
    include Spree::SoftDeletable

    belongs_to :variant, class_name: 'Spree::Variant'
  end
end
