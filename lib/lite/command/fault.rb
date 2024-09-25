# frozen_string_literal: true

module Lite
  module Command

    # Fault represent a stoppage of a call execution. This error should
    # not be raised directly since it wont provide any context. Use
    # `Noop`, `Invalid`, `Failure`, and `Error` to signify severity.
    class Fault < StandardError

      attr_reader :faulter, :thrower, :reason

      def initialize(faulter, thrower, reason)
        @faulter = faulter
        @thrower = thrower
        @reason = reason
        super(reason)
      end

      def type
        self.class.name.split("::").last.downcase
      end

    end

    # Noop represents skipping completion of call execution early
    # an unsatisfied condition or logic check where there is no
    # point on proceeding.
    # eg: account is sample: skip since its a non-alterable record
    class Noop < Fault; end

    # Invalid represents a stoppage of call execution due to
    # missing, bad, or corrupt data.
    # eg: user not found: stop since rest of the call cant be executed
    class Invalid < Fault; end

    # Failure represents a stoppage of call execution due to
    # an unsatisfied condition or logic check where it blocks
    # proceeding any further.
    # eg: record not found: stop since there is nothing todo
    class Failure < Fault; end

    # Error represents a caught exception for a call execution
    # that could not complete.
    # eg: ApiServerError: stop since there was a 3rd party issue
    class Error < Fault; end

  end
end
