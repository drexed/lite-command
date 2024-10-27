# frozen_string_literal: true

module Lite
  module Command
    class FaultStreamer

      attr_reader :command, :object

      def initialize(command, object)
        @command = command
        @object = object
      end

      def reason
        if object.respond_to?(:reason)
          object.reason
        elsif object.is_a?(StandardError)
          Utils.pretty_exception(object)
        else
          object
        end
      end

      def metadata
        Utils.try(object, :metadata) || command.metadata
      end

      def caused_by
        Utils.try(object, :caused_by) || command
      end

      def thrown_by
        return object if Utils.try(object, :executed?)

        Utils.try(object, :thrown_by) || command.caused_by
      end

      def fault_exception
        return if command.success?

        Fault.build(
          command.status.capitalize,
          command,
          object,
          dynamic: command.send(:raise_dynamic_faults?)
        )
      end

    end
  end
end
