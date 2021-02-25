# frozen_string_literal: true

module Spree
  class Seller < Spree::Base
    include Spree::SoftDeletable

    validates :name, presence: true, uniqueness: true
    validates :merchant_id, uniqueness: { case_sensitive: false }
    validates :percentage, numericality: {
                            greater_than_or_equal_to: 0, 
                            less_than_or_equal_to: 100
                           }, 
                           allow_blank: true
                           
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

    before_create :set_merchant_id

    def set_merchant_id
      self.merchant_id = SecureRandom.uuid
    end
  end
end
