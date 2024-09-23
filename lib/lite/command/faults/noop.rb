# frozen_string_literal: true

module Lite
  module Command
    module Faults
      # Noop represents a soft stoppage of call execution that
      # allows skipping to the next step or logical branch.
      # eg: record is a sample, skip since its a non-alterable record
      class Noop < Base; end
    end
  end
end
