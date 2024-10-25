# frozen_string_literal: true

module Lite
  module Command
    module Internals
      module Faults

        def self.included(base)
          base.class_eval { attr_reader :exception }
        end

        def caused_by
          return if success?

          @caused_by || self
        end

        def caused_fault?
          caused_by == self
        end

        def thrown_by
          return if success?

          @thrown_by || self
        end

        def threw_fault?
          thrown_by == self
        end

        def thrown?
          fault? && !caused_fault?
        end

        def raise!
          return if exception.nil?

          raise exception
        end

        private

        def throw!(command)
          return if command.success?

          send(:"#{command.status}!", command)
        end

        def raise_dynamic_faults?
          Lite::Command.configuration.raise_dynamic_faults
        end

      end
    end
  end
end
