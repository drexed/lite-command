# frozen_string_literal: true

module Lite
  module Command
    class Base

      def self.inherited(base)
        super

        base.extend Forwardable

        base.include Lite::Command::Internals::Runnable
        base.include Lite::Command::Internals::Callable
        base.include Lite::Command::Internals::Executable
        base.include Lite::Command::Internals::Resultable

        base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          # eg: Users::ResetPassword::Fault
          class #{base}::Fault < Lite::Command::Fault; end
        RUBY

        FAULTS.each do |call_fault|
          fault_method = call_fault.downcase.capitalize

          base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # eg: Users::ResetPassword::Noop < Users::ResetPassword::Fault
            class #{base}::#{fault_method} < #{base}::Fault; end
          RUBY
        end
      end

      attr_reader :context

      def initialize(context = {})
        @context = Lite::Command::Context.build(context)
      end

    end
  end
end
