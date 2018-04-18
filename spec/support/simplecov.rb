require 'simplecov'

SimpleCov.start(:rails) do
  add_filter('spec/dummy')
  add_filter('lib/generators')
end
