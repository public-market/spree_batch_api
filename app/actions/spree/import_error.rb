module Spree
  class ImportError < StandardError
    attr_reader :object

    def initialize(message, object = nil)
      super(message)
      @object = object
    end
  end
end
