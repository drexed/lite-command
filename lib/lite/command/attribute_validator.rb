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
          command.class.attributes.map do |method_name, options|
            Lite::Command::Attribute.new(command, method_name, options)
          end
      end

      def errors
        @errors ||= attributes.each_with_object({}) do |attribute, h|
          attribute.validate!
          next if attribute.valid?

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
