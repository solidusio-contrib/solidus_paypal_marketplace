# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '/admin/sellers/paypal_callbacks', type: :request do
  include Warden::Test::Helpers
  stub_authorization!

  subject(:do_request) { get '/admin/sellers/paypal_callbacks', params: params }

  let(:params) do
    {
      merchantIdInPayPal: merchant_id_in_paypal,
      merchantId: seller.merchant_id,
      permissionsGranted: permission_granted
    }
  end
  let(:merchant_id_in_paypal) { 'PayPal#1' }
  let(:merchant_id) { 'MerchantId' }
  let(:permission_granted) { true }
  let(:seller) { create(:pending_seller, merchant_id: merchant_id) }
  let(:user) { create(:seller_user, seller: seller) }

  before do
    login_as user
  end

  it 'updates the seller with the merchant_id_in_paypal' do
    expect { do_request }.to change { seller.reload.merchant_id_in_paypal }.from(nil).to(merchant_id_in_paypal)
  end

  it 'changes the seller status to waiting_paypal_confirmation' do
    expect { do_request }.to change { seller.reload.status }.from('pending').to('waiting_paypal_confirmation')
  end

  it 'shows the success message to the user' do
    do_request
    expect(flash[:success]).to eq I18n.t('spree.admin.paypal_callbacks.waiting_webhook_confirmation')
  end

  it { is_expected.to redirect_to('http://www.example.com/admin/sellers/dashboard?refresh_seller_status=true') }

  context 'when seller is not in pending state' do
    let(:seller) { create(:seller, merchant_id: merchant_id) }

    it "doesn't change the seller" do
      expect { do_request }.not_to(change { seller.reload.updated_at })
    end

    it 'shows the error message to the user' do
      do_request

      expect(flash[:error]).to eq I18n.t('spree.admin.paypal_callbacks.seller_already_processed')
    end

    it { is_expected.to redirect_to(:admin_sellers_dashboard) }
  end

  context 'when seller related with the merchant_id is different than the seller user' do
    let(:seller) { create(:seller, merchant_id: merchant_id) }
    let(:user) { create(:seller_user, seller: create(:seller)) }

    it "doesn't change the seller" do
      expect { do_request }.not_to(change { seller.reload.updated_at })
    end

    it 'shows the error message to the user' do
      do_request

      expect(flash[:error]).to eq I18n.t('spree.admin.paypal_callbacks.sign_up_link_not_related')
    end

    it { is_expected.to redirect_to(:admin_sellers_dashboard) }
  end

  context "when the user didn't give all the required permissions" do
    let(:permission_granted) { false }

    before do
      allow(seller).to receive(:start_onboarding_process).and_return('https://start.new.onboarding.process')
      allow(Spree::Seller).to receive(:find_by!).and_return(seller)
    end

    it 'restart the onboarding process on the seller' do
      do_request

      expect(Spree::Seller).to have_received(:find_by!).with(merchant_id: seller.merchant_id)
    end

    it 'shows the error message to the user' do
      do_request

      expect(flash[:error]).to eq I18n.t('spree.admin.paypal_callbacks.granted_permissions_insufficient')
    end

    it { is_expected.to redirect_to(:admin_sellers_dashboard) }
  end
end
