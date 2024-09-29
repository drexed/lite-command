# frozen_string_literal: true

module Lite
  module Command

    class Fault < StandardError

      attr_reader :origin, :source, :reason

      def initialize(origin, source, reason)
        super(reason)

        @origin = origin
        @source = source
        @reason = reason
      end

      def fault_klass
        @fault_klass ||= self.class.name.split("::").last
      end

      def fault_name
        @fault_name ||= fault_klass.downcase
      end

    end

    class Noop < Fault; end
    class Invalid < Fault; end
    class Failure < Fault; end
    class Error < Fault; end

  end
end
