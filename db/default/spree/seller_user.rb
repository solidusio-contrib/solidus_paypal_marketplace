# frozen_string_literal: true

def prompt_for_seller_password
  if ENV['SELLER_PASSWORD']
    password = ENV['SELLER_PASSWORD'].dup
    puts "Seller User Password #{password}"
  else
    print "Password [test123]: "
    password = $stdin.gets.strip
    password = 'test123' if password.blank?
  end

  password
end

def prompt_for_seller_email
  if ENV['SELLER_EMAIL']
    email = ENV['SELLER_EMAIL'].dup
    puts "Seller User Email #{email}"
  else
    print "Email [seller@example.com]: "
    email = $stdin.gets.strip
    email = 'seller@example.com' if email.blank?
  end

  email
end

def create_seller_user
  if ENV['AUTO_ACCEPT']
    password = 'test123'
    email = 'seller@example.com'
  else
    puts 'Create the seller user (press enter for defaults).'
    email = prompt_for_seller_email
    password = prompt_for_seller_password
  end
  attributes = {
    password: password,
    password_confirmation: password,
    email: email,
    login: email
  }

  if Spree::User.find_by(email: email)
    puts "\nWARNING: There is already a user with the email: #{email}, so no account changes were made.\n\n"
  else
    seller_user = Spree.user_class.new(attributes)
    role = Spree::Role.find_or_create_by(name: 'seller')
    seller_user.spree_roles << role
    seller_user.seller = Spree::Seller.first
    seller_user.generate_spree_api_key unless seller_user.spree_api_key
    if seller_user.save
      puts 'Done!'
    else
      puts "There were some problems with persisting a new seller user:"
      seller_user.errors.full_messages.each do |error|
        puts error
      end
    end
  end
end

if Spree.user_class.includes(:spree_roles).where("#{Spree::Role.table_name}.name" => "seller").empty?
  create_seller_user
else
  puts 'Seller user has already been created.'
  puts 'Would you like to create a new seller user? (yes/no)'
  if ["yes", "y"].include? $stdin.gets.strip.downcase
    create_seller_user
  else
    puts 'No seller user created.'
  end
end
