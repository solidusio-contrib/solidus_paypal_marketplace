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
        source.update(capture_id: response.params["result"].id)
      end
      response
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
  end
end
