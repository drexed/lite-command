# frozen_string_literal: true

module Lite
  module Command
    module Internals
      module Attributes

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods

          def required(*attributes, from: :context, **options)
            delegates(*attributes, from:)

            validates_each(*attributes, **options) do |command, method_name, _attr_value|
              next if command.errors.added?(from, :undefined) || command.errors.added?(method_name, :required)

              if !command.respond_to?(from, true)
                command.errors.add(from, :undefined, message: "is an undefined argument")
              elsif !command.send(from).respond_to?(method_name, true)
                command.errors.add(method_name, :required, message: "is a required argument")
              end
            end
          end

          def optional(*attributes, from: :context, **_options)
            delegates(*attributes, from:)
          end

          private

          def delegates(*attributes, from: :context)
            attributes.each do |method_name|
              define_method(method_name) do
                return unless respond_to?(from)

                Utils.try(send(from), method_name)
              end
            end
          end

        end

        def read_attribute_for_validation(method_name)
          Utils.try(self, method_name)
        rescue NameError
          # Do nothing, fallback to :undefined error
        end

        private

        def validate_context_attributes
          return if errors.empty?

          invalid!(errors.full_messages.join(". "), metadata: errors.messages)
        end

      end
    end
  end
end
