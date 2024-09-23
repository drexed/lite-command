# frozen_string_literal: true

module Lite
  module Command
    # Fault represent a stoppage of a call execution. This error should
    # not be raised directly since it wont provide any context.
    class Fault < StandardError

      attr_reader :faulter, :thrower, :reason

      def initialize(faulter, thrower, reason)
        @faulter = faulter
        @thrower = thrower
        @reason = reason
        super(reason)
      end

    end

    # Noop represents a soft stoppage of call execution that
    # allows skipping to the next step or logical branch.
    # eg: record is a sample, skip since its a non-alterable record
    class Noop < Fault; end

    # Failure represents a hard stoppage of call execution where
    # moving to the next step or logical branch is pointless.
    # eg: record no found, stop since we cant do anything without it
    class Failure < Fault; end
  end
end
