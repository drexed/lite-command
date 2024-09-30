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
          # eg: error(object)
          define_method(:"#{f}") do |object|
            derive_fault_from(object)
            @status = f
          end

          # eg: invalid!(object)
          define_method(:"#{f}!") do |object|
            send(:"#{f}", object)

            klass = raise_dynamic_faults? ? self.class : Lite::Command
            fault = build_fault(klass.const_get(f.capitalize), object)
            raise fault
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
