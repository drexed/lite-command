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
              attributes[method_name] = options

              define_method(method_name) do
                # return instance_variable_get(method_name) if instance_variable_defined?(method_name)

                attribute = Lite::Command::Attribute.new(self, method_name, options)
                # instance_variable_set(method_name, attribute.value)
                attribute.value
              end
            end
          end

          private

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
