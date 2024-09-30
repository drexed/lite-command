# frozen_string_literal: true

module Lite
  module Command
    class Base

      def self.inherited(base)
        super

        base.include Lite::Command::Internals::Callable
        base.include Lite::Command::Internals::Executable
        base.include Lite::Command::Internals::Faultable
        base.include Lite::Command::Internals::Resultable

        base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          # eg: Users::ResetPassword::Fault < Lite::Command::Fault
          #{base}::Fault = Class.new(Lite::Command::Fault)

          # eg: Users::ResetPassword::Noop < Users::ResetPassword::Fault
          #{base}::Noop    = Class.new(#{base}::Fault)
          #{base}::Invalid = Class.new(#{base}::Fault)
          #{base}::Failure = Class.new(#{base}::Fault)
          #{base}::Error   = Class.new(#{base}::Fault)
        RUBY
      end

      attr_reader :context
      alias ctx context

      def initialize(context = {})
        @context = Lite::Command::Context.build(context)
      end

      private

      def on_before_execution
        # Define in your class to run code before execution
      end

      def on_after_execution
        # Define in your class to run code after execution
      end

    end
  end
end
