# frozen_string_literal: true

module Lite
  module Command
    class Simple

      class << self

        def call(*args, **kwargs, &block)
          raise Lite::Command::NotImplementedError unless defined?(execute)

          execute(*args, **kwargs, &block)
        end

      end

    end
  end
end
