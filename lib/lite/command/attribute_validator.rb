# frozen_string_literal: true

module Lite
  module Command
    class AttributeValidator

      attr_reader :command

      def initialize(command)
        @command = command
      end

      def attributes
        @attributes ||=
          command.class.attributes.map do |_method_name, attribute|
            attribute.tap { |a| a.command = command }
          end
      end

      def errors
        @errors ||= attributes.each_with_object({}) do |attribute, h|
          next if attribute.tap(&:validate!).valid?

          h[attribute.from] ||= []
          h[attribute.from] = h[attribute.from] | attribute.errors
        end
      end

      def valid?
        attributes.empty? || errors.empty?
      end

    end
  end
end
