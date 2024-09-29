# frozen_string_literal: true

module Lite
  module Command
    module Internals
      module Faultable

        def self.included(base)
          base.class_eval do
            attr_reader :caused_by, :thrown_by, :reason
          end
        end

        def reason?(str)
          return true if str.nil?

          reason == str
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

        def throw!(command)
          return if command.success?

          send(:"#{command.status}!", command)
        end

        def derive_caused_by_from(fault_or_string)
          (fault_or_string.caused_by if fault_or_string.respond_to?(:caused_by)) || self
        end

        def derive_thrown_by_from(fault_or_string)
          if fault_or_string.respond_to?(:executed?) && fault_or_string.executed?
            fault_or_string
          else
            (fault_or_string.thrown_by if fault_or_string.respond_to?(:thrown_by)) || caused_by
          end
        end

        def derive_reason_from(fault_or_string)
          if fault_or_string.respond_to?(:reason)
            fault_or_string.reason
          elsif fault_or_string.respond_to?(:message)
            "[#{fault_or_string.class.name}] #{fault_or_string.message}".chomp(".")
          else
            fault_or_string
          end
        end

        def derive_fault_from(fault_or_string)
          @caused_by ||= derive_caused_by_from(fault_or_string)
          @thrown_by ||= derive_thrown_by_from(fault_or_string)
          @reason ||= derive_reason_from(fault_or_string)
        end

        # eg: Lite::Command::Noop.new(...)
        def raise_fault(klass, thrower)
          exception = klass.new(caused_by, self, reason)
          exception.set_backtrace(thrower.backtrace) if thrower.respond_to?(:backtrace)
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

      end
    end
  end
end
