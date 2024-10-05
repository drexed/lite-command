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
      module Execute

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
          Utils.hook(self, :on_before_execution)
          validate_context_attributes
          executing!
          Utils.hook(self, :on_executing)
        end

        def after_execution
          send(:"#{success? ? COMPLETE : INTERRUPTED}!")
          Utils.hook(self, :on_after_execution)
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
          Utils.hook(self, :on_success)
        rescue StandardError => e
          fault(e, ERROR, metadata) unless e.is_a?(Lite::Command::Fault)
          after_execution
          Utils.hook(self, :"on_#{status}", e)
        ensure
          Utils.hook(self, :"on_#{state}")
        end

        def execute!
          around_execution { call }
          Utils.hook(self, :on_success)
        rescue StandardError => e
          after_execution
          raise(e)
        end

      end
    end

  end
end
