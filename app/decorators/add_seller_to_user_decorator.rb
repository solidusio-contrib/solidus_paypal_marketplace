# frozen_string_literal: true

module AddSellerToUserDecorator
  def self.prepended(base)
    base.belongs_to :seller, class_name: 'Spree::Seller',
                             optional: true
  end

  Spree::User.prepend self
end
