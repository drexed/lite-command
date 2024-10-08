# frozen_string_literal: true

module Lite
  module Command
    module Internals
      module Context

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods

          def attribute(*args, **options)
            args.each do |method_name|
              attribute = Lite::Command::Attribute.new(method_name, options)
              attributes[method_name] = attribute

              define_method(method_name) do
                ivar = :"@#{method_name}"
                return instance_variable_get(ivar) if instance_variable_defined?(ivar)

                instance_variable_set(ivar, attribute.value)
              end
            end
          end

          def attributes
            @attributes ||= {}
          end

        end

        private

        def validate_context_attributes
          validator = Lite::Command::AttributeValidator.new(self)
          return if validator.valid?

          invalid!("Invalid context attributes", validator.errors)
        end

      end
    end
  end
end
