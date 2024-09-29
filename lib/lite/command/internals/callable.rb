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
            attr_reader :caused_by, :thrown_by, :reason
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

        def caused_fault?
          caused_by == self
        end

        def threw_fault?
          thrown_by == self
        end

        def thrown?
          fault? && !caused_fault?
        end

        FAULTS.each do |f|
          # eg: noop? or failure?("idk")
          define_method(:"#{f}?") do |r = nil|
            status == f && reason?(r)
          end
        end

        private

        def derive_caused_by_from(object)
          (object.caused_by if object.respond_to?(:caused_by)) || self
        end

        def derive_thrown_by_from(object)
          if object.respond_to?(:executed?) && object.executed?
            object
          else
            (object.thrown_by if object.respond_to?(:thrown_by)) || caused_by
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
          @caused_by ||= derive_caused_by_from(object)
          @thrown_by ||= derive_thrown_by_from(object)
          @reason ||= derive_reason_from(object)
        end

        # eg: Lite::Command::Noop.new(...)
        def raise_fault(klass, object)
          exception = klass.new(caused_by, self, reason)
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
