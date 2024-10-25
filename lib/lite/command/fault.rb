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

      def self.===(item)
        klass0 = respond_to?(:new) ? self : self.class
        klass1 = item.respond_to?(:new) ? item : item.class
        return true if klass0 == klass1

        klass0.ancestors.include?(klass1) || klass1.ancestors.include?(klass0)
      end

      def type
        @type ||= self.class.name.split("::").last.downcase
      end

      def ===(item)
        klass = item.respond_to?(:new) ? item : item.class
        is_a?(klass)
      end

    end

    class Noop < Fault; end
    class Invalid < Fault; end
    class Failure < Fault; end
    class Error < Fault; end

  end
end
