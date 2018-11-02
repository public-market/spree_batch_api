gem_root = File.dirname(File.dirname(File.dirname(__FILE__)))

Dir[File.join(gem_root, 'spec', 'factories', '**', '*.rb')].each do |factory|
  require(factory)
end
