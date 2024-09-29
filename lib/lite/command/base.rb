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
          # eg: Users::ResetPassword::Fault
          class #{base}::Fault < Lite::Command::Fault; end
        RUBY

        FAULTS.each do |f|
          base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # eg: Users::ResetPassword::Noop < Users::ResetPassword::Fault
            class #{base}::#{f.capitalize} < #{base}::Fault; end
          RUBY
        end
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
