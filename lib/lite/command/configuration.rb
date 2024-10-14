# frozen_string_literal: true

module Lite
  module Command

    class Configuration

      attr_accessor :max_call_depth, :raise_dynamic_faults

      def initialize
        @max_call_depth = Float::INFINITY
        @raise_dynamic_faults = false
      end

    end

    class << self

      attr_writer :configuration

      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end

      def reset_configuration!
        @configuration = Configuration.new
      end

    end

  end
end
