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

      end
    end
  end
end
