# frozen_string_literal: true

module AddOfferToVariantDecorator
  def self.prepended(base)
    base.has_many :offers, class_name: 'Spree::Offer'
  end

  Spree::Variant.prepend self
end
