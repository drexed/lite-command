# frozen_string_literal: true

module Lite
  module Command

    STATUSES = [
      SUCCESS = "success",
      NOOP    = "noop",
      INVALID = "invalid",
      FAILURE = "failure",
      ERROR   = "error"
    ].freeze
    FAULTS = (STATUSES - [SUCCESS]).freeze

    module Internals
      module Callable

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods

          def call(context = {})
            new(context).tap(&:execute)
          end

          def call!(context = {})
            new(context).tap(&:execute!)
          end

        end

        def call
          raise NotImplementedError, "call method not defined in #{self.class}"
        end

        def status
          @status || SUCCESS
        end

        def success?
          status == SUCCESS
        end

        def fault?(str = nil)
          !success? && reason?(str)
        end

        FAULTS.each do |f|
          # eg: noop? or failure?("idk")
          define_method(:"#{f}?") do |str = nil|
            status == f && reason?(str)
          end
        end

        private

        FAULTS.each do |f|
          # eg: error(fault_or_string)
          define_method(:"#{f}") do |fault_or_string|
            derive_fault_from(fault_or_string)
            @status = f
          end

          # eg: invalid!(fault_or_string)
          define_method(:"#{f}!") do |fault_or_string|
            send(:"#{f}", fault_or_string)
            raise_fault(Lite::Command.const_get(f.capitalize), fault_or_string)
          end

          # eg: on_noop(exception)
          define_method(:"on_#{f}") do |_exception|
            # Define in your class to run code when a
            # Lite::Command::Fault or StandardError happens
          end
        end

        alias fail! failure!

      end
    end

  end
end
