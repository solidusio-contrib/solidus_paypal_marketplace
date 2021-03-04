# frozen_string_literal: true

FactoryBot.define do
  factory :seller, class: 'Spree::Seller' do
    name { 'Seller Name' }
    percentage { 2.0 }
  end
end
