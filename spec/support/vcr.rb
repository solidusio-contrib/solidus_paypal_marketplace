# frozen_string_literal: true

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.ignore_localhost = true
  config.allow_http_connections_when_no_cassette = false

  # https://github.com/titusfortner/webdrivers/wiki/Using-with-VCR-or-WebMock
  driver_hosts = Webdrivers::Common.subclasses.map { |driver| URI(driver.base_url).host }
  config.ignore_hosts(*driver_hosts)
  config.filter_sensitive_data('<Authorization Code>') do |interaction|
    interaction.request.headers['Authorization']&.first
  end

  config.filter_sensitive_data('<Paypal Partner Attribution Id>') do |interaction|
    interaction.request.headers['Paypal-Partner-Attribution-Id']&.first
  end

  config.register_request_matcher :generic_partner_referral do |request1, request2|
    uri_without_ids1 = request1.uri
                               .gsub(%r{partners/[^/]*}, "partners/filtered-id")
                               .gsub(%r{merchant-integrations/.*}, "merchant-integrations/filtered-id")
    uri_without_ids2 = request2.uri
                               .gsub(%r{partners/[^/]*}, "partners/filtered-id")
                               .gsub(%r{merchant-integrations/.*}, "merchant-integrations/filtered-id")
    uri_without_ids1 == uri_without_ids2
  end

  config.after_http_request ->(request) {
    true || request.uri.include?('/partners/') && request.uri.include?('/merchant-integrations/')
  } do |request, _response|
    request.uri.gsub!(%r{partners/[^/]*}, "partners/filtered-id")
    request.uri.gsub!(%r{merchant-integrations/.*}, "merchant-integrations/filtered-id")
  end

  config.before_record(:paypal_api) do |interaction|
    body = JSON.parse(interaction.response.body)
    body["scope"] = 'FILTERED' if body["scope"]
    interaction.response.body = body.slice("links", "scope", "payments_receivable")
                                    .to_json
  end

  # Let's you set default VCR record mode with VCR_RECORDE_MODE=all for re-recording
  # episodes. :once is VCR default
  record_mode = ENV.fetch('VCR_RECORD_MODE', :once).to_sym
  config.default_cassette_options = { record: record_mode }
end

RSpec.configure do |config|
  config.around(:example, :vcr_off) do |e|
    VCR.turned_off(&e)
  end
end
