# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Webhooks
    module Handlers
      class Base
        attr_reader :params

        def self.call(context)
          new(context).call
        end

        def initialize(context)
          @context = context
        end

        def call
          raise NotImplementedError, 'Missing #call method on class'
        end

        private

        def resource
          @context.params[:resource]
        end
      end
    end
  end
end
