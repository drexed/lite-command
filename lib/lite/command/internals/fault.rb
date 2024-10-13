# frozen_string_literal: true

module Lite
  module Command
    module Internals
      module Fault

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

        private

        def throw!(command)
          return if command.success?

          send(:"#{command.status}!", command)
        end

        def raise_dynamic_faults?
          false # TODO: derive from config option
        end

      end
    end
  end
end
