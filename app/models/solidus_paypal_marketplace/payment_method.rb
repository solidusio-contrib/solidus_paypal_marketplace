# frozen_string_literal: true

module SolidusPaypalMarketplace
  class PaymentMethod < SolidusSupport.payment_method_parent_class
    include SolidusPaypalCommercePlatform::ButtonOptionsHelper
    preference :client_id, :string
    preference :client_secret, :string
    preference :partner_code, :string
    preference :paypal_button_color, :paypal_select, default: "gold"
    preference :paypal_button_size, :paypal_select, default: "responsive"
    preference :paypal_button_shape, :paypal_select, default: "rect"
    preference :paypal_button_layout, :paypal_select, default: "vertical"
    # preference :display_on_cart, :boolean, default: true  # NOT IMPLEMENTED YET
    # preference :display_on_product_page, :boolean, default: true # NOT IMPLEMENTED YET
    # preference :display_credit_messaging, :boolean, default: true # NOT IMPLEMENTED YET

    def partial_name
      "paypal_commerce_platform"
    end

    def auto_capture?
      false
    end

    def client_id
      options[:client_id]
    end

    def client_secret
      options[:client_secret]
    end

    def payment_source_class
      SolidusPaypalCommercePlatform::PaymentSource
    end

    def gateway_class
      SolidusPaypalMarketplace::Gateway
    end

    def button_style
      {
        color: options[:paypal_button_color] || "gold",
        size: options[:paypal_button_size] || "responsive",
        shape: options[:paypal_button_shape] || "rect",
        layout: options[:paypal_button_layout] || "vertical"
      }
    end

    def javascript_sdk_url(order: nil, currency: nil)
      # Both instance and class respond to checkout_steps.
      step_names = order ? order.checkout_steps : ::Spree::Order.checkout_steps.keys

      commit_immediately = step_names.include? "confirm"

      parameters = {
        'client-id': client_id,
        intent: auto_capture ? "capture" : "authorize",
        commit: commit_immediately ? "false" : "true",
        components: options[:display_credit_messaging] ? "buttons,messages" : "buttons",
        currency: currency
      }

      "https://www.paypal.com/sdk/js?#{parameters.to_query}"
    end
  end
end
