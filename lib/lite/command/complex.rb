# frozen_string_literal: true

module Lite
  module Command
    class Complex

      class << self

        def call(*args, **kwargs, &block)
          instance = new(*args, **kwargs, &block)

          raise Lite::Command::NotImplementedError unless instance.respond_to?(:execute)

          instance.call
          instance
        end

        def execute(*args, **kwargs, &block)
          instance = call(*args, **kwargs, &block)
          instance.result
        end

      end

      attr_reader :args, :result

      def initialize(*args)
        @args = args
      end

      def call
        raise Lite::Command::NotImplementedError unless defined?(execute)

        return @result if called?

        @called = true
        @result = execute
      end

      def called?
        @called ||= false
      end

      def recall!
        @called = false
        %i[cache errors].each { |method_name| send(method_name).clear if respond_to?(method_name) }
        call
      end

    end
  end
end
