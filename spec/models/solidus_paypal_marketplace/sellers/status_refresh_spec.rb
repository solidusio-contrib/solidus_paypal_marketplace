# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Sellers::StatusRefresh do
  subject(:status_refresh) { described_class.new(seller, return_url: return_url) }

  let(:seller) { create(:pending_seller, merchant_id_in_paypal: 'merchant-id', status: :waiting_paypal_confirmation) }
  let(:return_url) { 'url' }

  it do
    expect(described_class).to respond_to(:call).with_unlimited_arguments
  end

  it do
    expect(described_class).to respond_to(:new).with(1)
    expect(described_class).to respond_to(:new).with(1).arguments.and_keywords(:return_url)
  end

  it { is_expected.to respond_to(:call).with(0).arguments }
  it { is_expected.to respond_to(:unconfirmed_primary_email) }
  it { is_expected.to respond_to(:wrong_oauth_third_party_permissions) }

  describe '#call' do
    let(:merchant_id) { seller.merchant_id_in_paypal }
    let(:oauth_integration) do
      OpenStruct.new(
        integration_type: described_class.const_get('INTEGRATION_TYPE'),
        integration_method: described_class.const_get('INTEGRATION_METHOD'),
        oauth_third_party: [oauth_third_party]
      )
    end
    let(:oauth_third_party) do
      OpenStruct.new(
        partner_client_id: SolidusPaypalMarketplace.config.paypal_client_id,
        scopes: described_class.const_get('OAUTH_THIRD_PARTY_SCOPES')
      )
    end
    let(:payments_receivable) { true }
    let(:paypal_signup_link) { 'link' }
    let(:primary_email_confirmed) { true }
    let(:response) do
      OpenStruct.new(
        oauth_integrations: [oauth_integration],
        payments_receivable: payments_receivable,
        primary_email_confirmed: primary_email_confirmed
      )
    end

    before do
      SolidusPaypalMarketplace.config.paypal_client_id = 'partner-client-id'
      allow(SolidusPaypalMarketplace::PaypalPartnerSdk).to(
        receive(:show_seller_status).with(merchant_id: merchant_id)
                                    .and_return(response)
      )
      allow(SolidusPaypalMarketplace::PaypalPartnerSdk).to(
        receive(:generate_paypal_sign_up_link).with({ return_url: return_url, tracking_id: seller.merchant_id })
                                              .and_return(paypal_signup_link)
      )
    end

    it do
      expect(status_refresh.call).to be_kind_of(described_class)
    end

    it do
      expect(status_refresh.call.unconfirmed_primary_email).to eq(false)
    end

    it do
      expect(status_refresh.call.wrong_oauth_third_party_permissions).to eq(false)
    end

    it do
      expect { status_refresh.call }.to(
        change { status_refresh.seller.status }.from('waiting_paypal_confirmation').to('accepted')
      )
    end

    context 'when seller\'s primary email is not confirmed' do
      let(:primary_email_confirmed) { false }

      it do
        expect(status_refresh.call).to be_kind_of(described_class)
      end

      it do
        expect(status_refresh.call.unconfirmed_primary_email).to eq(true)
      end

      it do
        expect { status_refresh.call }.not_to(
          change { status_refresh.seller.status }.from('waiting_paypal_confirmation')
        )
      end
    end

    context 'when seller\'s oauth third party permissions are wrong' do
      let(:oauth_third_party) { OpenStruct.new }

      it do
        expect(status_refresh.call).to be_kind_of(described_class)
      end

      it do
        expect(status_refresh.call.wrong_oauth_third_party_permissions).to eq(true)
      end

      it do
        expect { status_refresh.call }.to(
          change { status_refresh.seller.status }.from('waiting_paypal_confirmation').to('pending')
        )
      end
    end

    context 'when seller\'s payments are not receivable' do
      let(:payments_receivable) { false }

      it do
        expect(status_refresh.call).to be_kind_of(described_class)
      end

      it do
        expect { status_refresh.call }.to(
          change { status_refresh.seller.status }.from('waiting_paypal_confirmation')
                                                 .to('require_paypal_verification')
        )
      end
    end
  end
end
