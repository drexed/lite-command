# frozen_string_literal: true

module Lite
  module Command
    module Extensions
      module Propagation

        private

        %i[archive destroy save].each do |action|
          define_method("#{action}_and_return!") do |klass|
            merge_errors!(klass) unless klass.send(action)
            klass
          end
        end

        def create_and_return!(klass, params)
          klass = klass.create(params)
          merge_errors!(klass) unless klass.errors.empty?
          klass
        end

        def update_and_return!(klass, params)
          merge_errors!(klass) unless klass.update(params)
          klass
        end

      end
    end
  end
end
