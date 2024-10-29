# frozen_string_literal: true

module Lite
  module Command

    HOOKS = [
      :after_initialize,
      :before_validation,
      :around_execution,
      :before_execution,
      :after_execution,
      *STATUSES.map { |s| :"on_#{s}" },
      *STATES.map { |s| :"on_#{s}" }
    ].freeze

    module Internals
      module Hooks

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods

          def hooks
            @hooks ||= Utils.try(superclass, :hooks).dup || {}
          end

          HOOKS.each do |h|
            define_method(h) do |*method_names, &block|
              method_names << block if block_given?
              method_names.each do |mn|
                hooks[h] ||= []
                hooks[h].push(mn)
              end
            end
          end

        end

        private

        def run_hooks(hook)
          hooks = self.class.hooks[hook]
          return if hooks.nil?

          hooks.each { |h| Utils.call(self, h) }
        end

      end
    end

  end
end
