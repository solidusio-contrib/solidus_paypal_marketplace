# frozen_string_literal: true

module SolidusPaypalMarketplace
  module Webhooks
    class Sorter
      def self.call(params)
        new(params).call
      end

      def initialize(params)
        @event = params[:event_type]
        @resource = params[:resource]
      end

      def call
        handler.call(@resource)
      end

      private

      def handler
        class_name = @event.split(/[.-]/)
                           .map(&:capitalize)
                           .join
        SolidusPaypalMarketplace::Webhooks::Handlers.const_get(class_name)
      end
    end
  end
end
