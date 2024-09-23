# frozen_string_literal: true

module Lite
  module Command
    module Faults
      # Failure represents a hard stoppage of call execution where
      # moving to the next step or logical branch is pointless.
      # eg: record no found, stop since we cant do anything without it
      class Failure < Base; end
    end
  end
end
