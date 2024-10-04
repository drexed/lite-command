# frozen_string_literal: true

module Lite
  module Command

    class Fault < StandardError

      attr_reader :caused_by, :thrown_by, :reason, :metadata

      def initialize(**params)
        @reason    = params.fetch(:reason)
        @metadata  = params.fetch(:metadata)
        @caused_by = params.fetch(:caused_by)
        @thrown_by = params.fetch(:thrown_by)

        super(reason)
      end

      # eg: Lite::Command::Noop.new(...) or Users::ResetPassword::Noop.new(...)
      # def self.build(**params)
      #   klass = params.delete(:dynamic) ? params.fetch(:thrown_by).class : Lite::Command
      #   fault = klass.const_get(params.delete(:type).to_s)
      #   fault = fault.new(**params)
      #   fault.set_backtrace(thrower.backtrace) if thrower.respond_to?(:backtrace)
      def self.build(type, command, thrown_exception, dynamic: false)
        klass = dynamic ? command.class : Lite::Command
        fault = klass.const_get(type.to_s)
        fault = fault.new(
          reason:    command.reason,
          metadata:  command.metadata,
          caused_by: command.caused_by,
          thrown_by: command
        )
        fault.set_backtrace(thrown_exception.backtrace) if thrown_exception.respond_to?(:backtrace)
        fault
      end

      def type
        @type ||= self.class.name.split("::").last.downcase
      end

    end

    class Noop < Fault; end
    class Invalid < Fault; end
    class Failure < Fault; end
    class Error < Fault; end

    class Bubble

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
