# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:example, :webmock) do |e|
    WebMock.disallow_net_connect!

    e.run

    WebMock.allow_net_connect!
  end
end
