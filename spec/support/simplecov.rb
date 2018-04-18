require 'simplecov'

SimpleCov.start(:rails) do
  add_filter('spec/dummy')
  add_filter('lib/generators')
  add_filter('lib/spree_batch_api/engine')
  add_filter('lib/spree_batch_api/version')
end
