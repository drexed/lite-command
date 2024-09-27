# frozen_string_literal: true

require "ostruct" unless defined?(OpenStruct)

module Lite
  module Command
    class Context < OpenStruct

      extend Forwardable

      def_delegators :to_h, :keys, :size, :values

      def self.init(attributes = {})
        # To save memory and speed up the access to an attribute, the accessor methods
        # of an attribute are lazy loaded at certain points. This means that the methods
        # are defined only when a set of defined actions are triggered. This allows construct
        # to only define the minimum amount of required methods to make your data structure work
        os = new(attributes)
        os.methods(false)
        os
      end

      def self.build(attributes = {})
        attributes.is_a?(self) ? attributes : init(attributes)
      end

      def merge!(attributes = {})
        attrs = attributes.is_a?(self.class) ? attributes.to_h : attributes
        attrs.each { |k, v| self[k] = v }
      end

    end
  end
end
