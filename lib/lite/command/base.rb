# frozen_string_literal: true

require "active_model" unless defined?(ActiveModel)

module Lite
  module Command
    class Base

      def self.inherited(base)
        super

        base.include ActiveModel::Validations

        base.include Internals::Runtimes
        base.include Internals::Attributes
        base.include Internals::Faults
        base.include Internals::Calls
        base.include Internals::Executions
        base.include Internals::Hooks
        base.include Internals::Results

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
        @context = Context.build(context)
        run_hooks(:after_initialize)
      end

    end
  end
end
