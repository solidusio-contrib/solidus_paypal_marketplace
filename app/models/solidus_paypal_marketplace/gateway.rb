# frozen_string_literal: true

module SolidusPaypalMarketplace
  class Gateway < SolidusPaypalCommercePlatform::Gateway
    def initialize(options) # rubocop:disable Lint/MissingSuper
      # Cannot use kwargs because of how the Gateway is initialize by Solidus.
      @client = Client.new(
        test_mode: options.fetch(:test_mode, nil),
        client_id: options.fetch(:client_id),
        client_secret: options.fetch(:client_secret),
        partner_code: options.fetch(:partner_code)
      )
      @options = options
    end

    def capture(money, _response_code, options)
      payment = options[:originator]
      source = payment.source
      order = payment.order
      request = PayPalCheckoutSdk::Payments::AuthorizationsCaptureRequest.new(source.authorization_id)
      capture_payload = generate_capture_payload(money, options[:currency])

      seller = order&.line_items&.first&.seller
      capture_payload = payload_with_payment_instruction(capture_payload, order, seller, options) if seller

      request.request_body(capture_payload)

      response = @client.execute_with_response(request)
      if response.success?
        source.update(
          capture_id: response.params["result"].id,
          response_status: response.params["result"].status.downcase
        )
      end
      response
    end

    def create_order(order, auto_capture)
      intent = auto_capture ? "CAPTURE" : "AUTHORIZE"
      request = OrdersCreateRequest.new
      paypal_order = SolidusPaypalMarketplace::CreatePaypalOrderPayload.new(order)
      request.request_body paypal_order.to_json(intent)
      @client.execute(request)
    end

    def void(_response_code, options)
      payment = options[:originator]
      authorization_id = payment.source.authorization_id
      request = AuthorizationsVoidRequest.new(authorization_id)
      request.headers["PayPal-Auth-Assertion"] = paypal_auth_assertion(payment)
      @client.execute_with_response(request)
    end

    private

    def generate_capture_payload(money, currency)
      {
        amount: {
          currency_code: currency,
          value: Money.new(money).dollars
        }
      }
    end

    def payload_with_payment_instruction(capture_payload, order, seller, _options)
      platform_fees = (order.total * (seller.percentage / 100.0)).round(2)

      capture_payload[:payment_instruction] = {
        disbursement_mode: 'INSTANT',
        platform_fees: [
          {
            amount: {
              currency_code: order.currency,
              value: platform_fees
            }
          }
        ]
      }

      capture_payload
    end

    def paypal_auth_assertion(payment)
      merchant_id_in_paypal = payment.request_env[:merchant_id_in_paypal]
      header = {
        "alg" => "none"
      }
      payload = {
        "iss" => SolidusPaypalMarketplace.config.paypal_client_id,
        "payer_id" => merchant_id_in_paypal
      }
      signature = ""
      [
        Base64.strict_encode64(header.to_json),
        Base64.strict_encode64(payload.to_json),
        signature
      ].join('.')
    end
  end
end
