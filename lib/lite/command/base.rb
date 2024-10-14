# frozen_string_literal: true

module Lite
  module Command
    class Base

      def self.inherited(base)
        super

        base.include Lite::Command::Internals::Context
        base.include Lite::Command::Internals::Call
        base.include Lite::Command::Internals::Execute
        base.include Lite::Command::Internals::Fault
        base.include Lite::Command::Internals::Result

        return unless Lite::Command.configuration.raise_dynamic_faults

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
        Utils.try(self, :on_pending)
      end

    end
  end
end
