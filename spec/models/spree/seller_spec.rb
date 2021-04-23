# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Seller, type: :model do
  subject(:seller) { create(:seller) }

  it { is_expected.to be_kind_of(Spree::SoftDeletable) }
  it { is_expected.to have_many(:users).dependent(:destroy) }
  it { is_expected.to have_many(:prices).dependent(:destroy) }
  it { is_expected.to have_one(:stock_location).dependent(:destroy) }
  it { is_expected.to have_many(:stock_items).through(:stock_location) }
  it { is_expected.to respond_to(:can_supply?).with(1..2).arguments }

  it do
    expect(described_class.new).to define_enum_for(:status).with_values(
      pending: 0,
      accepted: 1,
      rejected: 2,
      revoked: 3,
      require_paypal_verification: 4
    )
  end

  it do
    expect(described_class.new).to define_enum_for(:risk_status).with_values(
      subscribed: 0,
      subscribed_with_limit: 1,
      declined: 2,
      manual_review: 3,
      need_more_data: 4
    )
  end

  describe '#create' do
    it 'assign merchant_id' do
      expect(seller.merchant_id).to be_present
    end

    context 'when merchant id is present' do
      let(:seller) { described_class.new(merchant_id: 'merchant-id') }

      it 'does not override it' do
        expect { seller.save }.not_to(change(seller, :merchant_id))
      end
    end

    it 'creates default stock location' do
      expect { seller }.to change(Spree::StockLocation, :count).from(0)
    end

    context 'when the stock_location is provided' do
      subject(:seller) { create(:seller, stock_location: stock_location) }

      let(:stock_location) { create(:stock_location) }

      before { stock_location }

      it 'creates default stock location' do
        expect { seller }.not_to change(Spree::StockLocation, :count).from(1)
      end
    end

    context 'when users are present' do
      let(:seller) { described_class.new }
      let!(:role) { create(:role, name: 'seller') }

      before do
        seller.users.build
        seller.save
      end

      it 'assign seller role to users before validation' do
        seller.users.each do |user|
          expect(user.spree_roles.uniq).to eq [role]
        end
      end
    end
  end

  describe '#percentage' do
    it {
      expect(seller).to validate_presence_of(:percentage)
    }

    it {
      expect(seller).to validate_numericality_of(:percentage).is_greater_than_or_equal_to(0)
    }

    it {
      expect(seller).to validate_numericality_of(:percentage).is_less_than_or_equal_to(100)
    }
  end

  describe '#start_onboarding_process' do
    subject(:start_onboarding_process) { seller.start_onboarding_process }

    let(:action_url) { 'http://example.com/action_url' }
    let(:seller) { create(:pending_seller) }

    before do
      allow(SolidusPaypalMarketplace::PaypalPartnerSdk).to receive(:generate_paypal_sign_up_link).and_return(action_url)
    end

    it 'updates action_url with the new link' do
      expect { start_onboarding_process }.to change { seller.reload.action_url }.from(nil).to(action_url)
    end

    it 'returns the action_url' do
      expect(start_onboarding_process).to eq action_url
    end

    it 'calls generate_paypal_sign_up_link on PaypalPartnerSdk' do
      start_onboarding_process

      expect(SolidusPaypalMarketplace::PaypalPartnerSdk).to have_received(:generate_paypal_sign_up_link).with(
        tracking_id: seller.merchant_id,
        return_url: nil
      )
    end

    context 'when the return_url is provided' do
      subject(:start_onboarding_process) { seller.start_onboarding_process(return_url: return_url) }

      let(:return_url) { 'http://example.com/return_url' }

      it 'calls generate_paypal_sign_up_link on PaypalPartnerSdk' do
        start_onboarding_process

        expect(SolidusPaypalMarketplace::PaypalPartnerSdk).to have_received(:generate_paypal_sign_up_link).with(
          tracking_id: seller.merchant_id,
          return_url: return_url
        )
      end
    end
  end

  describe '#can_supply?' do
    let(:variant) { create(:variant) }
    let(:stock_item) { Spree::StockItem.find_or_create_by(variant: variant, stock_location: seller.stock_location) }

    context 'when the stock item is blank' do
      before do
        stock_item.destroy
      end

      it 'responds false' do
        expect(seller.can_supply?(variant)).to be false
      end
    end

    context 'when the stock item is present' do
      before do
        stock_item.set_count_on_hand(5)
      end

      it 'responds false if desired quantity exceeds seller\'s stock item count on hand' do
        expect(seller.can_supply?(variant, 10)).to be false
      end

      it 'responds true if desired quantity does not exceed seller\'s stock item count on hand' do
        expect(seller.can_supply?(variant, 5)).to be true
      end
    end
  end
end
