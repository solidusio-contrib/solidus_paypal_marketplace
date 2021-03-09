# frozen_string_literal: true

%w(
  seller_role
  seller
  seller_user
).each do |seed|
  puts "Loading seed file: #{seed}"
  require_relative "default/spree/#{seed}"
end
