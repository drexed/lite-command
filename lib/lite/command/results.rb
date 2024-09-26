# frozen_string_literal: true

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
        values.sort_by!(&:trace)
      end

    end
  end
end
