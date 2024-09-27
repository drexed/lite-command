# frozen_string_literal: true

module Lite
  module Command

    # State represents the state of the executable code. Once `execute`
    # is ran, it will always complete or dnf if a fault is thrown by a
    # child command.
    STATES = [
      PENDING = "pending",
      EXECUTING = "executing",
      COMPLETE = "complete",
      DNF = "dnf"
    ].freeze

    module Internals
      module Executable

        def execute
          around_execution { call }
        rescue Lite::Command::Fault => e
          send(:"#{e.fault_name}", e)
          after_execution
          send(:"on_#{e.fault_name}", e)
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

        STATES.each do |s|
          # eg: running?
          define_method(:"#{s}?") { state == s }

          # eg: dnf!
          define_method(:"#{s}!") { @state = s }
        end

        private

        def on_before_execution
          # Define in your class to run code before execution
        end

        def before_execution
          increment_execution_index
          start_monotonic_time
          executing!
          on_before_execution
        end

        def on_after_execution
          # Define in your class to run code after execution
        end

        def after_execution
          fault? ? dnf! : complete!
          on_after_execution
          stop_monotonic_time
          append_execution_result
        end

        def around_execution
          before_execution
          yield
          after_execution
        end

      end
    end

  end
end
