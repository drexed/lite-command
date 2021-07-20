# frozen_string_literal: true

module Lite
  module Command
    class Complex

      class << self

        def call(*args, **kwargs, &block)
          klass = new(*args, **kwargs, &block)
          raise Lite::Command::NotImplementedError unless klass.respond_to?(:execute)

          klass.call
          klass
        end

        def execute(*args, **kwargs, &block)
          klass = call(*args, **kwargs, &block)
          klass.result
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
        %i[cache errors].each { |mixin| send(mixin).clear if respond_to?(mixin) }
        call
      end

    end
  end
end
