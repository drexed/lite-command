# frozen_string_literal: true

module Lite
  module Command
    class Attribute

      attr_accessor :command
      attr_reader :method_name, :options, :errors

      def initialize(method_name, options)
        @method_name = method_name
        @options = options
        @errors = []
      end

      def from
        options[:from] || :context
      end

      def required?
        options.key?(:required)
      end

      def requirements
        return @requirements if defined?(@requirements)

        @requirements = Utils.call(command, options[:required])
      end

      def typed?
        (options.key?(:types) || options.key?(:type)) && types.any?
      end

      def types
        @types ||= begin
          t = Array(Utils.call(command, options[:types] || options[:type]))

          if reject_nil? || reject_empty?
            t.uniq - [NilClass]
          else
            t | [NilClass]
          end
        end
      end

      def value
        command.send(from).send(method_name)
      end

      def validate!
        validate_respond_attribute!
        return unless errors.empty?

        validate_required_attribute!
        validate_attribute_type!
      end

      def valid?
        errors.empty?
      end

      private

      def validate_respond_attribute!
        return if command.respond_to?(from, true)

        @errors << "is not defined or an attribute"
      end

      def validate_required_attribute!
        return unless required?

        if !command.send(from).respond_to?(method_name)
          @errors << "#{method_name} is required"
        elsif (reject_nil? || reject_empty?) && value.nil?
          @errors << "#{method_name} cannot be nil"
        elsif reject_empty? && Utils.try(value, :empty?)
          @errors << "#{method_name} cannot be empty"
        end
      end

      def validate_attribute_type!
        return unless typed?
        return if types.include?(value.class)

        @errors << "#{method_name} type invalid"
      end

      %i[reject_nil reject_empty].each do |key|
        define_method(:"#{key}?") do
          ivar = :"@#{key}"
          return instance_variable_get(ivar) if instance_variable_defined?(ivar)

          val = requirements.is_a?(Hash) && Utils.call(command, options.dig(:required, key))
          instance_variable_set(ivar, val)
        end
      end

    end
  end
end
