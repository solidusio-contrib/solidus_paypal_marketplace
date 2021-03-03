# frozen_string_literal: true

module Spree
  class Seller < Spree::Base
    include Spree::SoftDeletable

    enum status: {
      pending: 0,
      accepted: 1,
      rejected: 2
    }

    enum risk_status: {
      subscribed: 0,
      subscribed_with_limit: 1,
      declined: 2,
      manual_review: 3,
      need_more_data: 4
    }

    has_many :users, class_name: 'Spree::User',
                     dependent: :destroy

    has_one :stock_location, class_name: 'Spree::StockLocation',
                             dependent: :destroy,
                             inverse_of: :seller
    has_many :stock_items, through: :stock_location

    before_validation :set_merchant_id, on: :create

    after_create_commit :create_default_stock_location!

    validates :name, presence: true,
                     uniqueness: { case_sensitive: true }
    validates :merchant_id, presence: true,
                            uniqueness: { case_sensitive: false }
    validates :percentage, presence: true
    validates :percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
                           if: -> { percentage.present? }

    private

    def create_default_stock_location!
      create_stock_location!(name: "#{name} - default", propagate_all_variants: false)
    end

    def set_merchant_id
      self.merchant_id = SecureRandom.uuid
    end
  end
end
