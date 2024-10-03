# frozen_string_literal: true

module Lite
  module Command
    module Internals
      module Fault

        def self.included(base)
          base.class_eval do
            attr_reader :reason, :metadata, :caused_by, :thrown_by
          end
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

        private

        def reason?(str)
          return true if str.nil?

          reason == str
        end

        def throw!(command)
          return if command.success?

          send(:"#{command.status}!", command)
        end

        def raise_dynamic_faults?
          false
        end

        # eg: Lite::Command::Noop.new(...) or Users::ResetPassword::Noop.new(...)
        def runtime_fault(type, thrower)
          klass = raise_dynamic_faults? ? self.class : Lite::Command
          fault = klass.const_get(type.to_s)
          fault = fault.new(reason:, metadata:, caused_by:, thrown_by: self)
          fault.set_backtrace(thrower.backtrace) if thrower.respond_to?(:backtrace)
          fault
        end

        def derive_caused_by_from(object)
          (object.caused_by if object.respond_to?(:caused_by)) || self
        end

        def derive_thrown_by_from(object)
          return object if object.respond_to?(:executed?) && object.executed?

          (object.thrown_by if object.respond_to?(:thrown_by)) || caused_by
        end

        def derive_metadata_from(object)
          return unless object.respond_to?(:metadata)

          object.metadata
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

      end
    end
  end
end
