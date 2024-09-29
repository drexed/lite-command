# frozen_string_literal: true

module Lite
  module Command

    STATUSES = [
      SUCCESS = "success",
      NOOP = "noop",
      INVALID = "invalid",
      FAILURE = "failure",
      ERROR = "error"
    ].freeze
    FAULTS = (STATUSES - [SUCCESS]).freeze

    module Internals
      module Callable

        def self.included(base)
          base.extend ClassMethods
          base.class_eval do
            attr_reader :faulter, :thrower, :reason
          end
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

        def fault?(r = nil)
          !success? && reason?(r)
        end

        def reason?(r)
          return true if r.nil?

          reason == r
        end

        def faulter?
          faulter == self
        end

        def thrower?
          thrower == self
        end

        def thrown_fault?
          fault? && !faulter?
        end

        FAULTS.each do |f|
          # eg: noop? or failure?("idk")
          define_method(:"#{f}?") do |r = nil|
            status == f && reason?(r)
          end
        end

        private

        def derive_faulter_from(object)
          (object.faulter if object.respond_to?(:faulter)) || self
        end

        def derive_thrower_from(object)
          if object.respond_to?(:executed?) && object.executed?
            object
          else
            (object.thrower if object.respond_to?(:thrower)) || faulter
          end
        end

        def derive_reason_from(object)
          if object.respond_to?(:reason)
            object.reason
          elsif object.respond_to?(:message)
            "[#{object.class.name}] #{object.message}".chomp(".")
          else
            object
          end
        end

        def fault(object)
          @faulter ||= derive_faulter_from(object)
          @thrower ||= derive_thrower_from(object)
          @reason ||= derive_reason_from(object)
        end

        # eg: Lite::Command::Noop.new(...)
        def raise_fault(klass, object)
          exception = klass.new(faulter, self, reason)
          exception.set_backtrace(object.backtrace) if object.respond_to?(:backtrace)
          raise(exception)
        end

        # eg: Users::ResetPassword::Noop.new(...)
        def raise_dynamic_fault(exception)
          fault_klass = self.class.const_get(exception.fault_klass)
          raise_fault(fault_klass, exception)
        end

        def raise_dynamic_faults?
          false
        end

        def throw!(command)
          return if command.success?

          send(:"#{command.status}!", command)
        end

        FAULTS.each do |f|
          # eg: error(object)
          define_method(:"#{f}") do |object|
            fault(object)
            @status = f
          end

          # eg: invalid!(object)
          define_method(:"#{f}!") do |object|
            send(:"#{f}", object)
            raise_fault(Lite::Command.const_get(f.capitalize), object)
          end

          # eg: on_noop(exception)
          define_method(:"on_#{f}") do |_exception|
            # Define in your class to run code when a StandardError happens
          end
        end

        alias fail! failure!

      end
    end

  end
end
