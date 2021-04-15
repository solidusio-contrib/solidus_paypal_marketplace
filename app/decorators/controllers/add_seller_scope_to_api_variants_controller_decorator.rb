# frozen_string_literal: true

module AddSellerScopeToApiVariantsControllerDecorator
  private

  def scope
    return super unless params[:for_seller]

    scope_for_sellers(super)
  end

  def scope_for_sellers(collection)
    products_with_options = Spree::Product.joins(option_types: :option_values)
    collection.where(is_master: false, products: products_with_options)
              .or collection.where(is_master: true)
                            .where
                            .not(products: products_with_options)
  end

  Spree::Api::VariantsController.prepend(self)
end
