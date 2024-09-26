# frozen_string_literal: true

module Lite
  module Command

    # Status represents the state of the callable code. If no fault
    # is thrown then a status of SUCCESS is returned even if `call`
    # has not been executed.
    FAULTS = [
      NOOP = "NOOP",
      INVALID = "INVALID",
      FAILURE = "FAILURE",
      ERROR = "ERROR"
    ].freeze
    STATUSES = [
      *FAULTS,
      SUCCESS = "SUCCESS"
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
          FAULTS.any? { |f| send(:"#{f.downcase}?", message) }
        end

        def status
          STATUSES.find { |s| send(:"#{s.downcase}?") }
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

        FAULTS.each do |call_fault|
          fault_method = call_fault.downcase

          # eg: error?(message = nil)
          define_method(:"#{fault_method}?") do |message = nil|
            fault_result = instance_variable_get(:"@#{fault_method}") || false
            return fault_result if message.nil?

            reason == message
          end
        end

        private

        def fault(object)
          @faulter ||= object.try(:faulter) || self
          @thrower ||= object.try(:executed?) ? object : (object.try(:thrower) || faulter)
          @reason =
            if object.respond_to?(:reason)
              object.reason
            elsif object.respond_to?(:message)
              "[#{object.class.name}] #{object.message}".chomp(".")
            else
              object
            end
        end

        # eg: Lite::Command::Noop.new(...)
        def raise_fault(klass, object)
          exception = klass.new(faulter, self, reason)
          exception.set_backtrace(object.backtrace) if object.respond_to?(:backtrace)
          raise(exception)
        end

        # eg: Users::ResetPassword::Noop.new(...)
        # TODO: generate this on inheritance
        def raise_dynamic_fault(exception)
          fault_klass = self.class.const_get(exception.demodualized_name)
        rescue NameError
          self.class.const_set(exception.demodualized_name, Class.new(exception.class))
          fault_klass = self.class.const_get(exception.demodualized_name)
        ensure
          raise_fault(fault_klass, exception)
        end

        def raise_dynamic_faults?
          false
        end

        def throw!(command)
          return if command.success?

          send(:"#{command.status.downcase}!", command)
        end

        FAULTS.each do |call_fault|
          fault_method = call_fault.downcase

          # eg: error(object)
          define_method(:"#{fault_method}") do |object|
            fault(object)
            instance_variable_set(:"@#{fault_method}", true)
          end

          # eg: invalid!(object)
          define_method(:"#{fault_method}!") do |object|
            send(:"#{fault_method}", object)
            raise_fault(Lite::Command.const_get(fault_method.capitalize), object)
          end

          # eg: on_noop(exception)
          define_method(:"on_#{fault_method}") do |_exception|
            # Define in your class to run code when a StandardError happens
          end
        end

        alias fail! failure!

      end
    end

  end
end
