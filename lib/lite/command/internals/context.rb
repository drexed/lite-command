# frozen_string_literal: true

module Lite
  module Command
    module Internals
      module Context

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods

          def optional(*args, from: :context)
            args.each do |method_name|
              define_method(method_name) do
                send(from).public_send(method_name)
              end
            end
          end

          def required(*args, from: :context)
            required_context.merge!(from => args) { |_k, ov, nv| ov + nv }
            optional(*args, from:)
          end

          private

          def required_context
            @required_context ||= {}
          end

        end

        private

        def missing_context
          @missing_context ||=
            self.class.send(:required_context).each_with_object({}) do |(from, args), h|
              messages = args.filter_map do |method_name|
                next if respond_to?(from) && send(from).respond_to?(method_name)

                "#{method_name} is required"
              end

              h[from] = messages unless messages.empty?
            end
        end

        def validate_required_context
          return if self.class.send(:required_context).empty? || missing_context.empty?

          invalid!("Missing required context", missing_context)
        end

      end
    end
  end
end
