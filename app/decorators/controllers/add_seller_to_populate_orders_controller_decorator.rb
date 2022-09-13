# frozen_string_literal: true

module AddSellerToPopulateOrdersControllerDecorator
  def populate
    @order = current_order(create_order_if_necessary: true)
    authorize! :update, @order, cookies.signed[:guest_token]

    params[:variant_id], params[:seller_id] = params[:variant_and_seller_ids].split
    variant = Spree::Variant.find(params[:variant_id])
    quantity = params[:quantity].present? ? params[:quantity].to_i : 1

    # 2,147,483,647 is crazy. See issue https://github.com/spree/spree/issues/2695.
    if !quantity.between?(1, 2_147_483_647)
      @order.errors.add(:base, t('spree.please_enter_reasonable_quantity'))
    else
      begin
        @line_item = @order.contents.add(variant, quantity, options: { seller_id: params[:seller_id] })
      rescue ActiveRecord::RecordInvalid => e
        @order.errors.add(:base, e.record.errors.full_messages.join(", "))
      end
    end

    respond_with(@order) do |format|
      format.html do
        if @order.errors.any?
          flash[:error] = @order.errors.full_messages.join(", ")
          if Rails.gem_version > Gem::Version.new('7.0')
            redirect_back_or_to(spree.root_path)
          else
            redirect_back(fallback_location: spree.root_path)
          end
          return
        else
          redirect_to cart_path
        end
      end
    end
  end

  Spree::OrdersController.prepend self
end
