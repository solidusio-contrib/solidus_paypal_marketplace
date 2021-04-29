# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Webhooks::Handlers::Base do
  subject(:handler) { described_class.new({}) }

  it do
    expect(described_class).to respond_to(:call).with(1).arguments
  end

  it do
    expect(handler).to respond_to(:call).with(0).arguments
  end

  it do
    expect { handler.call }.to raise_exception(NotImplementedError)
  end
end
