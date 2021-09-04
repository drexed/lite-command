# frozen_string_literal: true

module Lite
  module Command
    module Extensions
      module Propagation

        private

        def assign_and_return!(instance, params)
          instance = instance.assign_attributes(params)
          errors.merge!(instance.errors) unless instance.valid?
          instance
        end

        def create_and_return!(klass, params)
          klass = klass.create(params)
          merge_errors!(klass) unless klass.errors.empty?
          klass
        end

        def update_and_return!(instance, params)
          merge_errors!(instance) unless instance.update(params)
          instance
        end

        %i[archive destroy save].each do |action|
          define_method("#{action}_and_return!") do |instance|
            merge_errors!(instance) unless instance.send(action)
            instance
          end
        end

      end
    end
  end
end
