# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Webhooks::Handlers::Base do
  subject(:do_call) { described_class.call(params) }

  it do
    expect(described_class).to respond_to(:call).with_unlimited_arguments
  end

  it do
    expect(described_class.new).to respond_to(:call).with_unlimited_arguments
  end

  it do
    expect { described_class.new.call }.to raise_exception(NotImplementedError)
  end
end
