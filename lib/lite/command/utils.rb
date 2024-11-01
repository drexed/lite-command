# frozen_string_literal: true

module Lite
  module Command
    module Utils

      module_function

      def monotonic_time
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def pretty_exception(exception)
        return if exception.nil?

        "[#{exception.class.name}] #{exception.message}".chomp(".")
      end

      def descendant_of?(object, other)
        object_class = object.respond_to?(:new) ? object : object.class
        other_class = other.respond_to?(:new) ? other : other.class

        !!(object_class <= other_class)
      end

      def cmd_try(object, method_name, *args, include_private: true)
        return unless object.respond_to?(method_name, include_private)

        object.send(method_name, *args)
      end

      def cmd_call(object, argument)
        if argument.is_a?(Symbol) || argument.is_a?(String)
          object.send(argument)
        elsif argument.is_a?(Proc)
          object.instance_eval(&argument)
        else
          argument
        end
      end

      def cmd_eval(object, options = {})
        if options[:if] && options[:unless]
          cmd_call(object, options[:if]) && !cmd_call(object, options[:unless])
        elsif options[:if]
          cmd_call(object, options[:if])
        elsif options[:unless]
          !cmd_call(object, options[:unless])
        else
          options.fetch(:default, true)
        end
      end

    end
  end
end
