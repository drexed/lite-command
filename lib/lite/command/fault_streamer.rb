# frozen_string_literal: true

module Lite
  module Command
    class FaultStreamer

      attr_reader :command, :object

      def initialize(command, object)
        @command = command
        @object = object
      end

      def caused_by
        try(object, :caused_by) || command
      end

      def thrown_by
        return object if object.respond_to?(:executed?) && object.executed?

        try(object, :thrown_by) || command.caused_by
      end

      def metadata
        try(object, :metadata) || command.metadata
      end

      def reason
        return object.reason if object.respond_to?(:reason)
        return object unless object.is_a?(StandardError)

        "[#{object.class.name}] #{object.message}".chomp(".")
      end

      private

      def try(obj, method_name, include_private: false)
        return unless obj.respond_to?(method_name, include_private)

        obj.send(method_name)
      end

    end
  end
end
