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
        rescue Lite::Command::Fault => e
          send(:"#{e.fault_method}", e)
          after_execution
          send(:"on_#{e.fault_method}", e)
        rescue StandardError => e
          error(e)
          after_execution
          on_error(e)
        end

        def execute!
          around_execution { call }
        rescue StandardError => e
          after_execution

          raise(e) unless raise_dynamic_faults? && e.is_a?(Lite::Command::Fault)

          raise_dynamic_fault(e)
        end

        def state
          @state || PENDING
        end

        def executed?
          dnf? || complete?
        end

        STATES.each do |execution_state|
          state_method = execution_state.downcase

          # eg: running?
          define_method(:"#{state_method}?") { state == execution_state }

          # eg: dnf!
          define_method(:"#{state_method}!") { @state = execution_state }
        end

        private

        def current_execution_time
          Time.respond_to?(:current) ? Time.current : Time.now
        end

        def before_execution_metadata
          metadata.started_at = current_execution_time
        end

        def on_before_execution
          # Define in your class to run code before execution
        end

        def before_execution
          before_execution_metadata
          advance_execution_trace
          executing!
          on_before_execution
        end

        def around_execution
          before_execution
          yield
          after_execution
        end

        def after_execution_metadata
          metadata.finished_at = current_execution_time
          metadata.runtime = metadata.finished_at - metadata.started_at
        end

        def on_after_execution
          # Define in your class to run code after execution
        end

        def after_execution
          fault? ? dnf! : complete!
          after_execution_metadata
          append_execution_result
          on_after_execution
        end

      end
    end

  end
end
