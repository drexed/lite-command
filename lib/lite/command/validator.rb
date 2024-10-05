# frozen_string_literal: true

module Lite
  module Command
    class Validator

      attr_reader :command

      def initialize(command)
        @command = command
      end

      def errors
        command.class.send(:attributes).each_with_object({}) do |(method_name, opts), h|
          from = opts[:from] || :context

          unless valid_from_attribute?(from)
            next (h[from] ||= []) << "does not respond to #{method_name}"
          end

          unless valid_required_attribute?(from, method_name, opts)
            (h[from] ||= []) << "#{method_name} is required"
          end

          unless valid_attribute_type?(from, method_name, opts)
            (h[from] ||= []) << "#{method_name} type invalid"
          end
        end
      end

      def valid?
        command.class.send(:attributes).empty? || errors.empty?
      end

      private

      def valid_from_attribute?(from)
        command.respond_to?(from)
      end

      def valid_required_attribute?(from, method_name, opts)
        return true unless opts[:required]

        command.send(from).respond_to?(method_name)
      end

      def valid_attribute_type?(from, method_name, opts)
        return true unless opts.key?(:type)

        value = command.send(from).public_send(method_name)
        Array(opts[:type]).include?(value.class)
      end

    end
  end
end
