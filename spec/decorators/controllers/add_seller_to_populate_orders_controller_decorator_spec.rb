# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AddSellerToPopulateOrdersControllerDecorator, type: :controller do
  let(:controller) { @controller = Spree::OrdersController.new }
  let!(:store) { create(:store) }
  let(:user) { create(:user) }

  context 'with Order model mock' do
    let(:order) do
      Spree::Order.create!
    end
    let(:seller) { create(:seller) }
    let(:variant) { create(:price, seller: seller).variant }

    before do
      allow(controller).to receive_messages(try_spree_current_user: user)
    end

    describe '#populate' do
      it 'creates a new order when none specified' do
        post :populate, params: { variant_and_seller_ids: [variant.id, seller.id].join(' ') }
        expect(response).to be_redirect
        expect(cookies.signed[:guest_token]).not_to be_blank

        order_by_token = Spree::Order.find_by(guest_token: cookies.signed[:guest_token])
        assigned_order = assigns[:order]

        expect(assigned_order).to eq order_by_token
        expect(assigned_order).to be_persisted
      end

      # rubocop:disable RSpec/NestedGroups
      context 'with Variant and Seller' do
        it 'handles population' do
          expect do
            post :populate, params: { variant_and_seller_ids: [variant.id, seller.id].join(' '), quantity: 5 }
          end.to change { user.orders.count }.by(1)
          order = user.orders.last
          expect(response).to redirect_to spree.cart_path
          expect(order.line_items.size).to eq(1)
          line_item = order.line_items.first
          expect(line_item).to have_attributes(
            variant_id: variant.id,
            seller_id: seller.id,
            quantity: 5
          )
        end

        it 'shows an error when population fails' do
          request.env["HTTP_REFERER"] = spree.root_path
          # rubocop:disable RSpec/AnyInstance
          allow_any_instance_of(Spree::LineItem).to(
            receive(:valid?).and_return(false)
          )
          allow_any_instance_of(Spree::LineItem).to(
            receive_message_chain(:errors, :full_messages). # rubocop:disable RSpec/MessageChain
              and_return(["Order population failed"])
          )
          # rubocop:enable RSpec/AnyInstance

          post :populate, params: { variant_and_seller_ids: [variant.id, seller.id].join(' '), quantity: 5 }

          expect(response).to redirect_to(spree.root_path)
          expect(flash[:error]).to eq("Order population failed")
        end

        it 'shows an error when quantity is invalid' do
          request.env["HTTP_REFERER"] = spree.root_path

          post(
            :populate,
            params: { variant_and_seller_ids: [variant.id, seller.id].join(' '), quantity: -1 }
          )

          expect(response).to redirect_to(spree.root_path)
          expect(flash[:error]).to eq(
            I18n.t('spree.please_enter_reasonable_quantity')
          )
        end

        context 'when quantity is empty string' do
          it 'populates order with 1 of given variant' do
            expect do
              post :populate, params: { variant_and_seller_ids: [variant.id, seller.id].join(' '), quantity: '' }
            end.to change { Spree::Order.count }.by(1)
            order = Spree::Order.last
            expect(response).to redirect_to spree.cart_path
            expect(order.line_items.size).to eq(1)
            line_item = order.line_items.first
            expect(line_item.variant_id).to eq(variant.id)
            expect(line_item.quantity).to eq(1)
          end
        end

        context 'when quantity is nil' do
          it 'populates order with 1 of given variant' do
            expect do
              post :populate, params: { variant_and_seller_ids: [variant.id, seller.id].join(' '), quantity: nil }
            end.to change { Spree::Order.count }.by(1)
            order = Spree::Order.last
            expect(response).to redirect_to spree.cart_path
            expect(order.line_items.size).to eq(1)
            line_item = order.line_items.first
            expect(line_item.variant_id).to eq(variant.id)
            expect(line_item.quantity).to eq(1)
          end
        end
      end
      # rubocop:enable RSpec/NestedGroups
    end
  end

  context 'when line items quantity is 0' do
    let(:order) { Spree::Order.create(store: store) }
    let(:seller) { create(:seller) }
    let(:variant) { create(:price, seller: seller).variant }
    let!(:line_item) { order.contents.add(variant, 1, options: { seller_id: seller.id }) }

    before do
      allow(controller).to receive :authorize!
      allow(controller).to receive_messages(current_order: order)
    end

    it 'removes line items on update' do
      expect(order.line_items.count).to eq 1
      put :update, params: { order: { line_items_attributes: { "0" => { id: line_item.id, quantity: 0 } } } }
      expect(order.reload.line_items.count).to eq 0
    end
  end
end
