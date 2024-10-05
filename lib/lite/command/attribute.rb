# frozen_string_literal: true

module Lite
  module Command
    class Attribute

      attr_reader :command, :method_name, :options, :errors

      def initialize(command, method_name, options)
        @command = command
        @method_name = method_name
        @options = options
        @errors = []
      end

      def from
        options[:from] || :context
      end

      def filled?
        options[:filled] || false
      end

      def required?
        options[:required] || false
      end

      def typed?
        options.key?(:types)
      end

      def types
        Array(options[:types])
      end

      def validate!
        validate_respond_attribute!
        return unless errors.empty?

        validate_required_attribute!
        validate_attribute_type!
        validate_attribute_filled!
      end

      def valid?
        errors.empty?
      end

      def value
        return @value if defined?(@value)

        @value = command.send(from).public_send(method_name)
      end

      private

      def validate_respond_attribute!
        return if command.respond_to?(from, true)

        @errors << "is not defined or an attribute"
      end

      def validate_required_attribute!
        return unless required?
        return if command.send(from).respond_to?(method_name)

        @errors << "#{method_name} is required"
      end

      def validate_attribute_type!
        return unless typed?
        return if types.include?(value.class)

        @errors << "#{method_name} type invalid"
      end

      def validate_attribute_filled!
        return unless filled?
        return unless value.nil?

        @errors << "#{method_name} must be filled"
      end

    end
  end
end
