# frozen_string_literal: true

module Lite
  module Command
    class Base

      def self.inherited(base)
        super

        base.include ActiveModel::Validations

        base.include Lite::Command::Internals::Attributes
        base.include Lite::Command::Internals::Calls
        base.include Lite::Command::Internals::Executions
        base.include Lite::Command::Internals::Faults
        base.include Lite::Command::Internals::Results

        if Lite::Command.configuration.raise_dynamic_faults # rubocop:disable Style/GuardClause
          base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            #{base}::Fault   = Class.new(Lite::Command::Fault)
            #{base}::Noop    = Class.new(#{base}::Fault)
            #{base}::Invalid = Class.new(#{base}::Fault)
            #{base}::Failure = Class.new(#{base}::Fault)
            #{base}::Error   = Class.new(#{base}::Fault)
          RUBY
        end
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
