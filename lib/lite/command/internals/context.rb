# frozen_string_literal: true

module Lite
  module Command
    module Internals
      module Context

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods

          def attribute(*args, **opts)
            args.each do |method_name|
              attributes[method_name] = opts

              define_method(method_name) do
                send(opts[:from] || :context).public_send(method_name)
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
          validator = Lite::Command::Validator.new(self)
          return if validator.valid?

          invalid!("Invalid context attributes", validator.errors)
        end

      end
    end
  end
end
