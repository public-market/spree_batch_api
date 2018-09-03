RSpec.describe Spree::Variant, type: :model do
  describe 'options assignment' do
    let(:variant) { Spree::Variant.new(product: create(:product)) }
    let(:opts) { [{ name: 'condition', value: 'New' }] }

    context 'when options=[]' do
      subject do
        variant.options = opts
        variant.new_record?
      end

      it { is_expected.to be false }
    end

    context 'when build_options' do
      subject do
        variant.build_options(opts)
        variant.new_record?
      end

      it { is_expected.to be true }
    end
  end
end
