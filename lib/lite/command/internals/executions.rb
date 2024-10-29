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
      module Executions

        def state
          @state || PENDING
        end

        def executed?
          complete? || interrupted?
        end

        STATES.each do |s|
          # eg: executing?
          define_method(:"#{s}?") { state == s }
        end

        private

        def executing!
          return unless pending?

          @state = EXECUTING
        end

        def complete!
          return if executed?

          @state = COMPLETE
        end

        def interrupted!
          return if executed?

          @state = INTERRUPTED
        end

        def before_execution
          increment_execution_index
          assign_execution_cmd_id
          start_monotonic_time
          run_hooks(:on_pending)
          validate_context_attributes
          run_hooks(:before_execution)
          executing!
          run_hooks(:on_executing)
        end

        def after_execution
          send(:"#{success? ? COMPLETE : INTERRUPTED}!")
          run_hooks(:after_execution)
          run_hooks(:"on_#{status}")
          run_hooks(:"on_#{state}")
          stop_monotonic_time
          append_execution_result
          freeze_execution_objects
        end

        def around_execution
          before_execution
          yield
          after_execution
        end

        def execute
          around_execution { call }
        rescue StandardError => e
          fault(e, Utils.try(e, :type) || ERROR, metadata, exception: e)
          after_execution
        end

        def execute!
          around_execution { call }
        rescue StandardError => e
          fault(e, Utils.try(e, :type) || ERROR, metadata, exception: e)
          after_execution
          raise(e)
        end

      end
    end

  end
end
