# frozen_string_literal: true

module Spree
  class Seller < Spree::Base
    include Spree::SoftDeletable

    enum status: { pending: 0, accepted: 1, rejected: 2 }
    enum risk_status: { subscribed: 0, subscribed_with_limit: 1, declined: 2, manual_review: 3, need_more_data: 4 }
  end
end
