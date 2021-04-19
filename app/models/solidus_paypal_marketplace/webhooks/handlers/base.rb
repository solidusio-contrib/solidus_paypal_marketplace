# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Webhooks
    module Handlers
      class Base
        attr_reader :params

        def self.call(params)
          new(params).call
        end

        def initialize(params)
          @params = params
        end

        def call
          raise NotImplementedError, 'Missing #call method on class'
        end

        private

        def seller
          Spree::Seller.find_by(merchant_id: params[:resource][:merchant_id])
        end
      end
    end
  end
end
