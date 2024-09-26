# frozen_string_literal: true

module Lite
  module Command
    class Trace < Construct

      include Comparable

      def increment(*keys)
        keys.each do |key|
          self[key] ||= 0
          self[key] += 1
        end
      end

      def advance(key)
        current_depth_keys = keys[0..keys.index(key)]
        trace = Lite::Command::Trace.init(to_h.slice(*current_depth_keys))
        trace.increment(:index, key)
        dependent_key?(key) ? Array(trace.position) << key : trace.position = [key]
        trace
      end

      def <=>(other)
        index <=> other.index
      end

      def traces
        to_h.except(:position, :index)
      end

      def to_position_fs
        traces.slice(*position).values.join("^")
      end

      def to_coordinates_fs
        points = traces.each_with_object([]) do |(k, v), a|
          dependent_key?(k) ? Array(a.last) << v : a << [v]
        end

        points.map { |v| v.join("^") }.join(".")
      end

      def to_formatted_s
        return if index.nil? || index.zero?

        position_fs = to_position_fs
        return index.to_s if position_fs.nil?

        "#{index}[#{position_fs}]"
      end
      alias to_fs to_formatted_s

      private

      def dependent_key?(key)
        key.to_s.start_with?("__")
      end

    end
  end
end
