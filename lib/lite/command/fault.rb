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
