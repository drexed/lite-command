# frozen_string_literal: true

require "forwardable" unless defined?(Forwardable)
require "active_model" unless defined?(ActiveModel)

module Lite
  module Command
    module Internals
      module Attributes

        def self.included(base)
          base.extend Forwardable
          base.extend ClassMethods
        end

        module ClassMethods

          def requires(*attributes, **options)
            from = options.delete(:from) || :context
            def_delegators(from, *attributes)

            validates_each(*attributes, **options) do |command, method_name, _attr_value|
              next if command.errors.added?(from, :undefined) || command.errors.added?(method_name, :required)

              if !command.respond_to?(from, true)
                command.errors.add(from, :undefined, message: "is an undefined argument")
              elsif !command.send(from).respond_to?(method_name, true)
                command.errors.add(method_name, :required, message: "is a required argument")
              end
            end
          end

          def optional(*attributes, from: :context)
            def_delegators(from, *attributes)
          end

        end

        private

        def validate_context_attributes
          return if errors.empty?

          invalid!(errors.full_messages.join(". "), errors.messages)
        end

      end
    end
  end
end
