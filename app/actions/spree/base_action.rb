require 'dry-initializer'

module Spree
  class BaseAction
    extend Dry::Initializer

    class << self
      def call(*args, &block)
        new(*args).call(&block)
      end
    end

    def call(*_args, &_block)
      raise NotImplementedError
    end

    protected

    def t(key, **options)
      I18n.t(key, scope: [:actions, self.class.name.underscore.tr('/', '.')], **options)
    end
  end
end
