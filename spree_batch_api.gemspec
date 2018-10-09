lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_batch_api/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_batch_api'
  s.version     = SpreeBatchApi.version
  s.summary     = 'Batch API extension allows to update product/inventory/orders in batches.'
  s.required_ruby_version = '>= 2.2.7'

  s.author    = 'Public Market Team'
  s.email     = 'team@publicmarket.io'
  s.homepage  = 'https://github.com/public-market/spree_batch_api'
  s.license = 'BSD-3-Clause'

  # s.files       = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'bulk_insert'
  s.add_dependency 'dry-initializer'
  s.add_dependency 'dry-validation'
  s.add_dependency 'paperclip'
  s.add_dependency 'sidekiq-scheduler'
  s.add_dependency 'sidekiq-status', '~> 1.0.0'
  s.add_dependency 'spree_core', '>= 3.1.0', '< 4.0'
  s.add_dependency 'spree_extension'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'pg', '0.21.0'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec-sidekiq'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'webmock'
end
