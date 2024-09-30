# frozen_string_literal: true

module Lite
  module Command

    class Fault < StandardError

      attr_reader :reason, :caused_by, :thrown_by

      def initialize(reason, caused_by, thrown_by)
        super(reason)

        @reason = reason
        @caused_by = caused_by
        @thrown_by = thrown_by
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
