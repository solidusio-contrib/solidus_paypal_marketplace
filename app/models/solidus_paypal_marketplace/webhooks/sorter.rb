# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Webhooks
    class Sorter
      def self.call(context)
        new(context).call
      end

      def initialize(context)
        @context = context
      end

      def call
        handler.call(@context)
      end

      private

      def handler
        class_name = event_type.split(/[.-]/)
                               .map(&:capitalize)
                               .join
        SolidusPaypalMarketplace::Webhooks::Handlers.const_get(class_name)
      end

      def event_type
        @context.params[:event_type]
      end
    end
  end
end
