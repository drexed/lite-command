# frozen_string_literal: true

module Lite
  module Command
    class Complex

      class << self

        def call(*args)
          klass = new(*args)
          klass.call
          klass
        end

        def run(*args)
          klass = call(*args)
          klass.result
        end

      end

      attr_reader :result

      def initialize(*args)
        @args = args
      end

      def call
        raise Lite::Command::NotImplementedError unless defined?(command)
        return @result if called?

        @called = true
        @result = command
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
