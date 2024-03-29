# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Sellers
    module ShipmentManagement
      class Base
        def self.call(*args)
          new.call(*args)
        end

        def call(*)
          raise NotImplementedError, 'Missing #call method on class'
        end
      end
    end
  end
end
