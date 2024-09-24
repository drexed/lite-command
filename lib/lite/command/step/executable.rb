# frozen_string_literal: true

module Lite
  module Command
    # State represents the state of the executable code. Once `execute`
    # is ran, it will always complete or dnf if a fault is thrown by a
    # child step.
    STATES = [
      PENDING = "PENDING",
      EXECUTING = "EXECUTING",
      COMPLETE = "COMPLETE",
      DNF = "DNF"
    ].freeze

    module Step
      module Executable

        def execute
          around_execution { call }
        rescue Lite::Command::Noop => e
          noop(e)
          after_execution
          on_noop(e)
        rescue Lite::Command::Failure => e
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

        # Any metadata added can be accessed throughout the step
        # lifecyle as well as dumped in to the `to_hash` method
        def assign_metadata_before_execution
          metadata.started_at = Time.current
        end

        def on_before_execution
          # Define in your class to run code before execution
        end

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

        def assign_metadata_after_execution
          metadata.finished_at = Time.current
          metadata.runtime = metadata.finished_at - metadata.started_at
        end

        def on_after_execution
          # Define in your class to run code after execution
        end

        def after_execution
          fault? ? dnf! : complete!
          assign_metadata_after_execution
          append_current_result
          on_after_execution
        end

      end
    end
  end
end
