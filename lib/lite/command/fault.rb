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

  end
end
