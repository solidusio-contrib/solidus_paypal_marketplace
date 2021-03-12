# frozen_string_literal: true

require 'spec_helper'
require 'cancan/matchers'

RSpec.describe Spree::PermissionSets::PaypalCallbacks do
  subject(:ability) { Spree::Ability.new(user) }

  let(:user) { nil }

  describe 'manage paypal_callbacks' do
    it 'cannot manage paypal_callbacks' do
      expect(ability).not_to be_able_to([:create, :admin], :paypal_callbacks)
    end

    context 'when the user is provided without roles' do
      let(:user) { create(:user) }

      it 'cannot manage paypal_callbacks' do
        expect(ability).not_to be_able_to([:create, :admin], :paypal_callbacks)
      end
    end

    context "when the user doesn't have the seller role" do
      let(:user) { create(:admin_user) }

      it 'cannot manage paypal_callbacks' do
        expect(ability).not_to be_able_to([:create, :admin], :paypal_callbacks)
      end
    end

    context "when the user has the seller role" do
      let(:user) { create(:seller_user) }

      it 'can manage paypal_callbacks' do
        expect(ability).to be_able_to([:create, :admin], :paypal_callbacks)
      end
    end
  end
end
