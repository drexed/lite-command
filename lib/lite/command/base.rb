# frozen_string_literal: true

module Lite
  module Command
    class Base

      def self.inherited(base)
        base.extend Forwardable
        base.include Lite::Command::Internals::Traceable
        base.include Lite::Command::Internals::Callable
        base.include Lite::Command::Internals::Executable
        base.include Lite::Command::Internals::Resultable
        base.class_eval do
          # eg: Users::ResetPassword::Fault
          eval("class #{base}::Fault < Lite::Command::Fault; end")

          FAULTS.each do |call_fault|
            fault_method = call_fault.downcase.capitalize

            # eg: Users::ResetPassword::Noop < Users::ResetPassword::Fault
            eval("class #{base}::#{fault_method} < #{base}::Fault; end")
          end

          attr_reader :context, :metadata
        end
      end

      def initialize(context = {})
        @context = Lite::Command::Construct.build(context)
        @metadata = Lite::Command::Construct.init
      end

    end
  end
end
