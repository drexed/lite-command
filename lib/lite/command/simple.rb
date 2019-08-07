# frozen_string_literal: true

module Lite
  module Command
    class Simple

      class << self

        def call(*args)
          raise Lite::Command::NotImplementedError unless defined?(command)

          command
        end

      end

    end
  end
end
