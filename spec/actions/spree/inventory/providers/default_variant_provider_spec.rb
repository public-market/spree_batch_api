RSpec.describe Spree::Inventory::Providers::DefaultVariantProvider, type: :action do
  subject(:variant) { described_class.call(item_json, options: options) }

  let(:options) { {} }

  describe 'validation' do
    module Spree
      module Inventory
        module Providers
          FakeValidationSchema =
            ::Dry::Validation.Schema do
              required(:notes).filled(:str?)
            end
        end
      end
    end

    let(:item_json) { { ean: 'isbn' } }

    it { expect { variant }.to raise_error(Spree::ImportError).with_message(include(":sku=>[\"is missing\"]")) }

    context 'with schema in options' do
      let(:options) { { validation_schema: 'fake' } }

      it { expect { variant }.to raise_error(Spree::ImportError).with_message(include(":notes=>[\"is missing\"]")) }

      context 'with incorrect schema' do
        let(:options) { { validation_schema: 'not existing schema' } }

        it { expect { variant }.to raise_error(Spree::ImportError, I18n.t('actions.spree.inventory.providers.incorrect_validation_schema', schema: 'not existing schema')) }
      end
    end
  end
end