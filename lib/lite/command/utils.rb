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

    end
  end
end
