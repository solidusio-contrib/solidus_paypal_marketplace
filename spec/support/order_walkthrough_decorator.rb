# frozen_string_literal: true

require 'spree/testing_support/order_walkthrough'

module Spree
  module TestingSupport
    class MarketplaceOrderWalkthrough < OrderWalkthrough
      def self.up_to(state, opts = {})
        new.up_to(state, **opts)
      end

      def up_to(state, order: nil, line_item: nil)
        # Need to create a valid zone too...
        @zone = ::FactoryBot.create(:zone)
        @country = ::FactoryBot.create(:country)
        @state = ::FactoryBot.create(:state, country: @country)

        @zone.members << Spree::ZoneMember.create(zoneable: @country)

        # A shipping method must exist for rates to be displayed on checkout page
        ::FactoryBot.create(:shipping_method, zones: [@zone]).tap do |sm|
          sm.calculator.preferred_amount = 10
          sm.calculator.preferred_currency = Spree::Config[:currency]
          sm.calculator.save
        end

        order ||= Spree::Order.create!(
          email: "solidus@example.com",
          store: Spree::Store.first || ::FactoryBot.create(:store)
        )
        add_line_item!(order) if line_item.nil?
        order.next!

        states_to_process = if state == :complete
                              states
                            else
                              end_state_position = states.index(state.to_sym)
                              states[0..end_state_position]
                            end

        states_to_process.each do |state_to_process|
          send(state_to_process, order)
        end

        order
      end
    end
  end
end
