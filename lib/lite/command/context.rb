# frozen_string_literal: true

require "ostruct" unless defined?(OpenStruct)

module Lite
  module Command
    class Context < OpenStruct

      def self.build(attributes = {})
        return attributes if attributes.is_a?(self) && !attributes.frozen?

        # To save memory and speed up the access to an attribute, the accessor methods
        # of an attribute are lazy loaded at certain points. This means that the methods
        # are defined only when a set of defined actions are triggered. This allows context
        # to only define the minimum amount of required methods to make your data structure work
        os = new(attributes.to_h)
        os.methods(false)
        os
      end

      def merge!(attributes = {})
        attributes.to_h.each { |k, v| self[k] = v }
      end

    end
  end
end
