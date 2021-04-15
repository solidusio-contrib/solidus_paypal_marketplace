# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::Webhooks::Sorter do
  subject(:do_call) { described_class.call(params) }

  let(:params) { { event_type: event_type, resource: {} } }
  let(:event_type) { 'EVENT.TYPE' }

  it do
    expect(described_class).to respond_to(:new).with(1).arguments
  end

  it do
    expect(described_class).to respond_to(:call).with(1).arguments
  end

  it do
    expect(described_class.new({})).to respond_to(:call).with(0).arguments
  end

  describe '#call' do
    context 'when the handler is not defined' do
      it do
        expect { do_call }.to raise_exception(NameError)
          .with_message(/uninitialized constant SolidusPaypalMarketplace::Webhooks::Handlers::EventType/)
      end
    end

    context 'when the handler is defined' do
      let(:result) { 'result' }
      let(:event_type) { 'BASE' }
      let(:handler) { instance_double(SolidusPaypalMarketplace::Webhooks::Handlers::Base) }

      before do
        allow(SolidusPaypalMarketplace::Webhooks::Handlers::Base).to receive(:new).and_return(handler)
        allow(handler).to receive(:call).and_return(result)
      end

      it do
        expect { do_call }.not_to raise_exception
      end

      it do
        expect(do_call).to be result
      end
    end
  end
end
