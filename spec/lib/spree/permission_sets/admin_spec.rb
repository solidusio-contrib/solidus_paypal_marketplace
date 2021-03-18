# frozen_string_literal: true

require 'spec_helper'
require 'cancan/matchers'

RSpec.describe Spree::PermissionSets::Admin do
  subject(:ability) { Spree::Ability.new(user) }

  let(:user) { nil }

  [
    :seller_dashboard,
    :seller_prices,
    :paypal_callbacks
  ].each do |page|
    describe "visit #{page}" do
      it "cannot visit #{page}" do
        expect(ability).not_to be_able_to([:visit], page)
      end

      context 'when the user is provided without roles' do
        let(:user) { create(:user) }

        it "cannot visit #{page}" do
          expect(ability).not_to be_able_to([:visit], page)
        end
      end

      context "when the user doesn't have the seller role" do
        let(:user) { create(:admin_user) }

        it "cannot visit #{page}" do
          expect(ability).not_to be_able_to([:visit], page)
        end
      end

      context "when the user has the seller role" do
        let(:user) { create(:seller_user) }

        it "can visit #{page}" do
          expect(ability).to be_able_to([:visit], page)
        end
      end
    end
  end
end
