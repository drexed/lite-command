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
            attr_reader :origin, :source, :reason
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

        def origin?
          origin == self
        end

        def source?
          source == self
        end

        def thrown?
          fault? && !origin?
        end

        FAULTS.each do |f|
          # eg: noop? or failure?("idk")
          define_method(:"#{f}?") do |r = nil|
            status == f && reason?(r)
          end
        end

        private

        def derive_origin_from(object)
          (object.origin if object.respond_to?(:origin)) || self
        end

        def derive_source_from(object)
          if object.respond_to?(:executed?) && object.executed?
            object
          else
            (object.source if object.respond_to?(:source)) || origin
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
          @origin ||= derive_origin_from(object)
          @source ||= derive_source_from(object)
          @reason ||= derive_reason_from(object)
        end

        # eg: Lite::Command::Noop.new(...)
        def raise_fault(klass, object)
          exception = klass.new(origin, self, reason)
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
