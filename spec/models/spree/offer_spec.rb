# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Offer, type: :model do
  it { is_expected.to be_kind_of Spree::SoftDeletable }
  it { is_expected.to belong_to(:variant).class_name('Spree::Variant') }
end
