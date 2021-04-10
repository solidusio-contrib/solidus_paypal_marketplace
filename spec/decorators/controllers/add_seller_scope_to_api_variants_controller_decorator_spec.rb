# frozen_string_literal: true

require 'spec_helper'
require 'spree/api/testing_support/helpers'

RSpec.describe AddSellerScopeToApiVariantsControllerDecorator, type: :controller do
  include Spree::Api::TestingSupport::Helpers

  let(:controller) { @controller = Spree::Api::VariantsController.new }
  let(:do_get) { get :index, format: :json, params: params }
  let(:option_type) { product_with_options.option_types.first }
  let(:params) { { q: 'Pro' } }
  let(:product_with_options) { create(:product_with_option_types) }

  let!(:master) { create(:product).master }
  let!(:master_with_variants) { product_with_options.master }
  let!(:variant) { create(:variant, product: product_with_options) }

  before do
    stub_authentication!
    create(:option_value, option_type: option_type)
    do_get
  end

  it "includes master variants for products without options" do
    expect(assigns[:variants]).to include(master)
  end

  it "includes variants" do
    expect(assigns[:variants]).to include(variant)
  end

  it "includes master variants for products with options" do
    expect(assigns[:variants]).to include(master_with_variants)
  end

  describe '#scope' do
    context 'when for_seller param is present' do
      let(:params) { { for_seller: true } }

      it "includes master variants for products without options" do
        expect(assigns[:variants]).to include(master)
      end

      it "includes variants" do
        expect(assigns[:variants]).to include(variant)
      end

      it "excludes master variants for products with options" do
        expect(assigns[:variants]).not_to include(master_with_variants)
      end
    end
  end
end
