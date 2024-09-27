# frozen_string_literal: true

require "forwardable" unless defined?(Forwardable)

module Lite
  module Command
    class Results

      extend Forwardable

      include Enumerable

      attr_reader :values

      def_delegators :values, :any?, :empty?, :each, :map, :none?, :size

      def initialize
        @values = []
      end

      def <<(value)
        values << value
        values.sort_by!(&:result_index)
      end

    end
  end
end
