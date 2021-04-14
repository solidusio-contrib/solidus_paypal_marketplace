# frozen_string_literal: true

module AddSellerToUserDecorator
  def self.prepended(base)
    base.belongs_to :seller, class_name: 'Spree::Seller',
                             optional: true

    base.validates_presence_of :seller, if: -> { has_spree_role?(:seller) }
  end

  Spree.user_class.prepend self
end
