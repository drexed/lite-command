# frozen_string_literal: true

module Lite
  module Command
    class Simple

      class << self

        def call(*args)
          raise Lite::Command::NotImplementedError unless defined?(execute)

          execute(*args)
        end

      end

    end
  end
end
