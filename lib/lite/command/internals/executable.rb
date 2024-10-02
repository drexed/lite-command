# frozen_string_literal: true

module Lite
  module Command

    STATES = [
      PENDING     = "pending",
      EXECUTING   = "executing",
      COMPLETE    = "complete",
      INTERRUPTED = "interrupted"
    ].freeze

    module Internals
      module Executable

        def execute
          around_execution { call }
          on_success if respond_to?(:on_success, true)
        rescue StandardError => e
          f = e.respond_to?(:type) ? e.type : ERROR

          fault(e, f)
          after_execution
          send(:"on_#{f}", e) if respond_to?(:"on_#{f}", true)
        end

        def execute!
          around_execution { call }
          on_success if respond_to?(:on_success, true)
        rescue StandardError => e
          after_execution
          raise(e)
        end

        def state
          @state || PENDING
        end

        def executed?
          complete? || interrupted?
        end

        STATES.each do |s|
          # eg: executing?
          define_method(:"#{s}?") { state == s }

          # eg: interrupted!
          define_method(:"#{s}!") { @state = s }
        end

        private

        def before_execution
          increment_execution_index
          assign_execution_cid
          start_monotonic_time
          executing!
          on_before_execution if respond_to?(:on_before_execution, true)
        end

        def after_execution
          fault? ? interrupted! : complete!
          on_after_execution if respond_to?(:on_after_execution, true)
          stop_monotonic_time
          append_execution_result
          freeze_execution_objects
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
