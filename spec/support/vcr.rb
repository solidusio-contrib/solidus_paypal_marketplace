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
