# frozen_string_literal: true

module Lite
  module Command
    module Utils

      module_function

      def try(object, method_name, *args, include_private: false)
        return unless object.respond_to?(method_name, include_private)

        object.send(method_name, *args)
      end

      def hook(object, method_name, *args)
        try(object, method_name, *args, include_private: true)
      end

      def call(object, method_name_or_proc)
        if method_name_or_proc.is_a?(Symbol) || method_name_or_proc.is_a?(String)
          object.send(method_name_or_proc)
        else
          object.instance_eval(&method_name_or_proc)
        end
      end

    end
  end
end
