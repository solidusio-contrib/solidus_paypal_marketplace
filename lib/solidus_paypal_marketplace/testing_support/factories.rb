# frozen_string_literal: true

FactoryBot.define do
  factory :base_seller, class: 'Spree::Seller' do
    sequence(:name) { |n| "Seller ##{n}" }
    percentage { 20 }

    factory :pending_seller do
      status { :pending }
    end

    factory :seller do
      status { :accepted }
    end
  end

  factory :seller_user, parent: :user do
    transient do
      seller_role { Spree::Role.find_or_create_by!(name: 'seller') }
    end
    spree_roles { [seller_role] }
    seller factory: :seller
  end
end

FactoryBot.modify do
  factory :line_item, class: 'Spree::LineItem' do
    seller do
      variant.prices.first&.seller || create(:seller)
    end
  end
end
