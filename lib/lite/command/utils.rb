# frozen_string_literal: true

module Lite
  module Command
    module Utils

      module_function

      def descendant_of?(object, other)
        object_class = object.respond_to?(:new) ? object : object.class
        other_class = other.respond_to?(:new) ? other : other.class

        !!(object_class <= other_class)
      end

      def try(object, method_name, *args, include_private: true)
        return unless object.respond_to?(method_name, include_private)

        object.send(method_name, *args)
      end

      def call(object, argument)
        if argument.is_a?(Symbol) || argument.is_a?(String)
          object.send(argument)
        elsif argument.is_a?(Proc)
          object.instance_eval(&argument)
        else
          argument
        end
      end

      def evaluate(object, options = {})
        if options[:if]
          call(object, options[:if])
        elsif options[:unless]
          !call(object, options[:unless])
        else
          options.fetch(:default, true)
        end
      end

    end
  end
end
