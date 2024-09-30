# frozen_string_literal: true

module Lite
  module Command

    STATES = [
      PENDING   = "pending",
      EXECUTING = "executing",
      COMPLETE  = "complete",
      DNF       = "dnf"
    ].freeze

    module Internals
      module Executable

        def execute
          around_execution { call }
        rescue StandardError => e
          f = e.respond_to?(:type) ? e.type : ERROR

          send(:"#{f}", e)
          after_execution
          send(:"on_#{f}", e)
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

        STATES.each do |s|
          # eg: executing?
          define_method(:"#{s}?") { state == s }

          # eg: dnf!
          define_method(:"#{s}!") { @state = s }
        end

        private

        def before_execution
          increment_execution_index
          assign_execution_cid
          start_monotonic_time
          executing!
          on_before_execution
        end

        def after_execution
          fault? ? dnf! : complete!
          on_after_execution
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
