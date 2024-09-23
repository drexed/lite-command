# frozen_string_literal: true

module Lite::Command
  class Results
    include Enumerable

    attr_reader :values

    delegate :any?, :empty?, :each, :map, :none?, :size, to: :values

    def initialize
      @values = []
    end

    def <<(value)
      values << value
      values.sort_by!(&:trace)
    end
  end
end
