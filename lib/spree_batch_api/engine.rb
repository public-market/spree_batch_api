require 'versioncake'

module SpreeBatchApi
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_batch_api'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    # Rabl.configure do |config|
    #   config.include_json_root = false
    #   config.include_child_root = false

    #   config.json_engine = ActiveSupport::JSON
    # end

    initializer 'spree.api.versioncake' do |_app|
      VersionCake.setup do |config|
        config.resources do |r|
          r.resource(/.*/, [], [], [1])
        end

        config.missing_version = 1
        config.extraction_strategy = :http_header
      end
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    require 'paperclip'
    Paperclip::UriAdapter.register # used by UpdateInventoryItem image uploader, possibly vulnerable

    config.to_prepare(&method(:activate).to_proc)
  end
end
