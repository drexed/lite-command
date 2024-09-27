# frozen_string_literal: true

module Lite
  module Command

    # Status represents the state of the callable code. If no fault
    # is thrown then a status of SUCCESS is returned even if `call`
    # has not been executed.
    FAULTS = [
      NOOP = "noop",
      INVALID = "invalid",
      FAILURE = "failure",
      ERROR = "error"
    ].freeze
    STATUSES = [
      *FAULTS,
      SUCCESS = "success"
    ].freeze

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

        def success?
          !fault?
        end

        def fault?(message = nil)
          FAULTS.any? { |f| send(:"#{f}?", message) }
        end

        def status
          STATUSES.find { |s| send(:"#{s}?") }
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
          # eg: error?(message = nil)
          define_method(:"#{f}?") do |message = nil|
            fault_result = instance_variable_get(:"@#{f}") || false
            return fault_result if message.nil?

            reason == message
          end
        end

        private

        def fault_faulter(object)
          (object.faulter if object.respond_to?(:faulter)) || self
        end

        def fault_thrower(object)
          if object.respond_to?(:executed?) && object.executed?
            object
          else
            (object.thrower if object.respond_to?(:thrower)) || faulter
          end
        end

        def fault_reason(object)
          if object.respond_to?(:reason)
            object.reason
          elsif object.respond_to?(:message)
            "[#{object.class.name}] #{object.message}".chomp(".")
          else
            object
          end
        end

        def fault(object)
          @faulter ||= fault_faulter(object)
          @thrower ||= fault_thrower(object)
          @reason ||= fault_reason(object)
        end

        # eg: Lite::Command::Noop.new(...)
        def raise_fault(klass, object)
          exception = klass.new(faulter, self, reason)
          exception.set_backtrace(object.backtrace) if object.respond_to?(:backtrace)
          raise(exception)
        end

        # eg: Users::ResetPassword::Noop.new(...)
        def raise_dynamic_fault(exception)
          fault_klass = self.class.const_get(exception.demodualized_name)
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
            instance_variable_set(:"@#{f}", true)
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
