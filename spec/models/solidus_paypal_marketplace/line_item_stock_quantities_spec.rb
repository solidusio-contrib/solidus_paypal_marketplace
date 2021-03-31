# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusPaypalMarketplace::LineItemStockQuantities, type: :model do
  subject(:described_instance) do
    described_class.new(quantities)
  end

  let(:line_item1) { mock_model(Spree::LineItem) }
  let(:line_item2) { mock_model(Spree::LineItem) }

  describe '#each' do
    def expect_each
      expect { |b| subject.each(&b) }
    end

    context 'with no items' do
      let(:quantities) { {} }

      it "doesn't yield" do
        expect_each.not_to yield_control
      end
    end

    context 'with one item' do
      let(:quantities) { { line_item1 => 2 } }

      it 'yields values' do
        expect_each.to yield_with_args([line_item1, 2])
      end
    end

    context 'with two items' do
      let(:quantities) { { line_item1 => 2, line_item2 => 3 } }

      it 'yields values' do
        expect_each.to yield_successive_args([line_item1, 2], [line_item2, 3])
      end
    end
  end

  describe '#line_items' do
    subject { described_class.new(quantities).line_items }

    context 'with one item' do
      let(:quantities) { { line_item1 => 2 } }

      it { is_expected.to eq [line_item1] }
    end

    context 'with two items' do
      let(:quantities) { { line_item1 => 2, line_item2 => 3 } }

      it { is_expected.to eq [line_item1, line_item2] }
    end
  end

  describe '#empty?' do
    context 'when there are no variants' do
      let(:quantities) { {} }

      it { is_expected.to be_empty }
    end

    context 'when quantity is 0' do
      let(:quantities) { { line_item1 => 0 } }

      it { is_expected.to be_empty }
    end

    context 'when quantity is positive' do
      let(:quantities) { { line_item1 => 1 } }

      it { is_expected.not_to be_empty }
    end

    context 'when one variant is positive and another is zero' do
      let(:quantities) { { line_item1 => 1, line_item2 => 0 } }

      it { is_expected.not_to be_empty }
    end

    context 'when quantity is negative' do
      # empty? doesn't make a whole lot of sense in this case, but returning
      # false is probably more accurate.
      let(:quantities) { { line_item1 => -1 } }

      it { is_expected.not_to be_empty }
    end
  end

  describe '==' do
    subject do
      described_class.new(quantity1) == described_class.new(quantity2)
    end

    context 'when both empty' do
      let(:quantity1) { {} }
      let(:quantity2) { {} }

      it { is_expected.to be true }
    end

    context 'when both equal' do
      let(:quantity1) { { line_item1 => 1 } }
      let(:quantity2) { { line_item1 => 1 } }

      it { is_expected.to be true }
    end

    context 'with different order' do
      let(:quantity1) { { line_item1 => 1, line_item2 => 2 } }
      let(:quantity2) { { line_item2 => 2, line_item1 => 1 } }

      it { is_expected.to be true }
    end

    context 'with different variant' do
      let(:quantity1) { { line_item1 => 1 } }
      let(:quantity2) { { line_item2 => 1 } }

      it { is_expected.to be false }
    end

    context 'with different quantities' do
      let(:quantity1) { { line_item1 => 1 } }
      let(:quantity2) { { line_item1 => 2 } }

      it { is_expected.to be false }
    end

    context 'when nil != 0' do
      let(:quantity1) { { line_item1 => 0 } }
      let(:quantity2) { {} }

      it { is_expected.to be false }
    end
  end

  describe '+' do
    subject do
      described_class.new(quantity1) + described_class.new(quantity2)
    end

    context 'with same variant' do
      let(:quantity1) { { line_item1 => 20 } }
      let(:quantity2) { { line_item1 => 22 } }

      it { is_expected.to eq described_class.new(line_item1 => 42) }
    end

    context 'with different variants' do
      let(:quantity1) { { line_item1 => 1 } }
      let(:quantity2) { { line_item2 => 2 } }

      it { is_expected.to eq described_class.new(line_item1 => 1, line_item2 => 2) }
    end

    context 'when quantities is 0' do
      let(:quantity1) { { line_item1 => 0 } }
      let(:quantity2) { { line_item2 => 1 } }

      it { is_expected.to eq described_class.new(line_item1 => 0, line_item2 => 1) }
    end

    context 'when quantity is empty' do
      let(:quantity1) { { line_item1 => 1 } }
      let(:quantity2) { {} }

      it { is_expected.to eq described_class.new(line_item1 => 1) }
    end
  end

  describe '-' do
    subject do
      described_class.new(quantity1) - described_class.new(quantity2)
    end

    context 'with same variant' do
      let(:quantity1) { { line_item1 => 22 } }
      let(:quantity2) { { line_item1 => 20 } }

      it { is_expected.to eq described_class.new(line_item1 => 2) }
    end

    context 'with different variants' do
      let(:quantity1) { { line_item1 => 1 } }
      let(:quantity2) { { line_item2 => 2 } }

      it { is_expected.to eq described_class.new(line_item1 => 1, line_item2 => -2) }
    end

    context 'when quantity is 0' do
      let(:quantity1) { { line_item1 => 0 } }
      let(:quantity2) { { line_item1 => 1 } }

      it { is_expected.to eq described_class.new(line_item1 => -1) }
    end

    context 'when quantity RHS is empty' do
      let(:quantity1) { { line_item1 => 1 } }
      let(:quantity2) { {} }

      it { is_expected.to eq described_class.new(line_item1 => 1) }
    end

    context 'when quantity LHS is empty' do
      let(:quantity1) { {} }
      let(:quantity2) { { line_item1 => 1 } }

      it { is_expected.to eq described_class.new(line_item1 => -1) }
    end
  end

  # Common subset
  describe '&' do
    subject do
      described_class.new(quantity1) & described_class.new(quantity2)
    end

    context 'with same variant' do
      let(:quantity1) { { line_item1 => 20 } }
      let(:quantity2) { { line_item1 => 22 } }

      it { is_expected.to eq described_class.new(line_item1 => 20) }
    end

    context 'with multiple variants' do
      let(:quantity1) { { line_item1 => 10, line_item2 => 20 } }
      let(:quantity2) { { line_item1 => 12, line_item2 => 14 } }

      it { is_expected.to eq described_class.new(line_item1 => 10, line_item2 => 14) }
    end

    context 'with different variants' do
      let(:quantity1) { { line_item1 => 1 } }
      let(:quantity2) { { line_item2 => 2 } }

      it { is_expected.to be_empty }
      it { is_expected.to eq described_class.new({}) }
    end

    context 'when quantities is 0' do
      let(:quantity1) { { line_item1 => 0 } }
      let(:quantity2) { { line_item1 => 1 } }

      it { is_expected.to eq described_class.new(line_item1 => 0) }
    end

    context 'when quantity is empty' do
      let(:quantity1) { { line_item1 => 1 } }
      let(:quantity2) { {} }

      it { is_expected.to eq described_class.new({}) }
    end
  end
end
