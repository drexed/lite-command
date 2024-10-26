# frozen_string_literal: true

module Lite
  module Command

    class Fault < StandardError

      attr_reader :reason, :metadata, :caused_by, :thrown_by

      def initialize(**params)
        @reason    = params.fetch(:reason)
        @metadata  = params.fetch(:metadata)
        @caused_by = params.fetch(:caused_by)
        @thrown_by = params.fetch(:thrown_by)

        super(reason)
      end

      def self.build(type, catcher, thrower, dynamic: false)
        klass = dynamic ? catcher.class : Lite::Command
        fault = klass.const_get(type.to_s)
        fault = fault.new(
          reason: catcher.reason,
          metadata: catcher.metadata,
          caused_by: catcher.caused_by,
          thrown_by: catcher.thrown_by
        )
        fault.set_backtrace(thrower.backtrace) if thrower.respond_to?(:backtrace)
        fault
      end

      def self.===(object)
        Utils.descendant_of?(self, object) || Utils.descendant_of?(object, self)
      end

      def type
        @type ||= self.class.name.split("::").last.downcase
      end

      def ===(object)
        Utils.descendant_of?(self, object)
      end

    end

    class Noop < Fault; end
    class Invalid < Fault; end
    class Failure < Fault; end
    class Error < Fault; end

  end
end
