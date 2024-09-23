# frozen_string_literal: true

# :reek:ModuleInitialize
module Lite::Command
  module Step
    # State represents the state of the executable code. Once the
    # `execute` is ran it will always complete or dnf if a fault
    # is thrown by a child step.
    STATES = [
      PENDING = "PENDING",
      EXECUTING = "EXECUTING",
      COMPLETE = "COMPLETE",
      DNF = "DNF"
    ].freeze

    # Status represents the state of the callable code. If no fault
    # is thrown then a status of SUCCESS is returned even if `call`
    # has not been executed.
    STATUSES = [
      SUCCESS = "SUCCESS",
      NOOP = "NOOP",
      FAILURE = "FAILURE"
    ].freeze

    def self.included(base)
      base.include Lite::Command::Step::Traceable
      base.include Lite::Command::Step::Resultable
      base.include Lite::Command::Step::Callable
      base.include Lite::Command::Step::Executable
      base.include Lite::Command::Step::Debuggable

      base.class_eval { attr_reader :context, :metadata }
    end

    def initialize(context = {})
      @print_format = context.try(:delete, :print)
      @context = Lite::Command::Construct.build(context)
      @metadata = Lite::Command::Construct.init
    end

    private

    def trace_key
      # Define in your class to enable tracing
    end

    def print_title
      # Define in your class to add a print title
    end

    def on_before_execution
      # Define in your class to run code before execution
    end

    def on_after_execution
      # Define in your class to run code after execution
    end

    def on_noop(_error)
      # Define in your class to run code when a NOOP happens
    end

    def on_failure(_error)
      # Define in your class to run code when a Failure happens
    end

    def on_error(error)
      # Define in your class to run code when a StandardError happens
    end

    # Any metadata added can be accessed throught the step lifecyle
    # as well as dumped in to the `to_hash` method
    def assign_metadata_before_execution
      metadata.started_at = Time.current
    end

    def assign_metadata_after_execution
      metadata.finished_at = Time.current
      metadata.runtime = metadata.finished_at - metadata.started_at
    end
  end
end
