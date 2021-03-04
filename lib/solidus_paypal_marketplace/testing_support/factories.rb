# frozen_string_literal: true

FactoryBot.define do
  factory :seller, class: 'Spree::Seller' do
    name { 'Seller Name' }
    percentage { 2.0 }
  end

  factory :seller_user, parent: :user do
    transient do
      seller_role { Spree::Role.find_or_create_by!(name: 'seller') }
    end
    spree_roles { [seller_role] }
    seller factory: :seller
  end
end
