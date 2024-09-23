# frozen_string_literal: true

module Lite
  module Command
    module Step
      module Executable

        extend ActiveSupport::Concern

        # State represents the state of the executable code. Once the
        # `execute` is ran it will always complete or dnf if a fault
        # is thrown by a child step.
        STATES = [
          PENDING = "PENDING",
          EXECUTING = "EXECUTING",
          COMPLETE = "COMPLETE",
          DNF = "DNF"
        ].freeze

        def execute
          around_execution { call }
        rescue Lite::Command::Faults::Noop => e
          noop(e)
          after_execution
          on_noop(e)
        rescue Lite::Command::Faults::Failure => e
          failure(e)
          after_execution
          on_failure(e)
        rescue StandardError => e
          failure(e)
          after_execution
          on_error(e)
        end

        def execute!
          around_execution { call }
        rescue StandardError => e
          after_execution
          raise(e)
        end

        def state
          @state || PENDING
        end

        def executed?
          dnf? || complete?
        end

        # # Getter methods of defined states, eg: running?, dnf!
        STATES.each do |execution_state|
          state_method = execution_state.downcase
          define_method(:"#{state_method}?") { state == execution_state }
          define_method(:"#{state_method}!") { @state = execution_state }
        end

        private

        def before_execution
          assign_metadata_before_execution
          advance_execution_trace
          executing!
          on_before_execution
        end

        def around_execution
          before_execution
          yield
          after_execution
        end

        def after_execution
          fault? ? dnf! : complete!
          assign_metadata_after_execution
          append_current_result
          on_after_execution
          print_execution_results
        end

      end
    end
  end
end
