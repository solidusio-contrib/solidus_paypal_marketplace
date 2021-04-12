require 'spec_helper'

RSpec.describe Spree::User, type: :model do
  subject(:seller_user) { create(:seller_user) }

  it do
    expect(seller_user.spree_api_key).to be_present
  end
end
