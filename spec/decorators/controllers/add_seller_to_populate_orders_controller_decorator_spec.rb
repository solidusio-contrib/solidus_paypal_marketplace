# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AddSellerToPopulateOrdersControllerDecorator, type: :controller do
  let(:controller) { @controller = described_class.new }
  let(:described_class) { Spree::OrdersController }
  let!(:store) { create(:store) }
  let(:user) { create(:user) }

  context "Order model mock" do
    let(:order) do
      Spree::Order.create!
    end
    let(:variant) { create(:variant) }

    before do
      allow(controller).to receive_messages(try_spree_current_user: user)
    end

    context "#populate" do
      it "should create a new order when none specified" do
        post :populate, params: { variant_id: variant.id }
        expect(response).to be_redirect
        expect(cookies.signed[:guest_token]).not_to be_blank

        order_by_token = Spree::Order.find_by(guest_token: cookies.signed[:guest_token])
        assigned_order = assigns[:order]

        expect(assigned_order).to eq order_by_token
        expect(assigned_order).to be_persisted
      end

      context "with Variant" do
        it "should handle population" do
          expect do
            post :populate, params: { variant_id: variant.id, quantity: 5 }
          end.to change { user.orders.count }.by(1)
          order = user.orders.last
          expect(response).to redirect_to spree.cart_path
          expect(order.line_items.size).to eq(1)
          line_item = order.line_items.first
          expect(line_item.variant_id).to eq(variant.id)
          expect(line_item.quantity).to eq(5)
        end

        it "shows an error when population fails" do
          request.env["HTTP_REFERER"] = spree.root_path
          allow_any_instance_of(Spree::LineItem).to(
            receive(:valid?).and_return(false)
          )
          allow_any_instance_of(Spree::LineItem).to(
            receive_message_chain(:errors, :full_messages).
              and_return(["Order population failed"])
          )

          post :populate, params: { variant_id: variant.id, quantity: 5 }

          expect(response).to redirect_to(spree.root_path)
          expect(flash[:error]).to eq("Order population failed")
        end

        it "shows an error when quantity is invalid" do
          request.env["HTTP_REFERER"] = spree.root_path

          post(
            :populate,
            params: { variant_id: variant.id, quantity: -1 }
          )

          expect(response).to redirect_to(spree.root_path)
          expect(flash[:error]).to eq(
            I18n.t('spree.please_enter_reasonable_quantity')
          )
        end

        context "when quantity is empty string" do
          it "should populate order with 1 of given variant" do
            expect do
              post :populate, params: { variant_id: variant.id, quantity: '' }
            end.to change { Spree::Order.count }.by(1)
            order = Spree::Order.last
            expect(response).to redirect_to spree.cart_path
            expect(order.line_items.size).to eq(1)
            line_item = order.line_items.first
            expect(line_item.variant_id).to eq(variant.id)
            expect(line_item.quantity).to eq(1)
          end
        end

        context "when quantity is nil" do
          it "should populate order with 1 of given variant" do
            expect do
              post :populate, params: { variant_id: variant.id, quantity: nil }
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
    end
  end

  context "line items quantity is 0" do
    let(:order) { Spree::Order.create(store: store) }
    let(:variant) { create(:variant) }
    let!(:line_item) { order.contents.add(variant, 1) }

    before do
      allow(controller).to receive :authorize!
      allow(controller).to receive_messages(current_order: order)
    end

    it "removes line items on update" do
      expect(order.line_items.count).to eq 1
      put :update, params: { order: { line_items_attributes: { "0" => { id: line_item.id, quantity: 0 } } } }
      expect(order.reload.line_items.count).to eq 0
    end
  end
end
