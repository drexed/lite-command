# frozen_string_literal: true

module Lite
  module Command

    HOOKS = [
      :after_initialize,
      :before_validation,
      :after_validation,
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
            @hooks ||= Utils.cmd_try(superclass, :hooks).dup || {}
          end

          HOOKS.each do |h|
            define_method(h) do |*method_names, &block|
              method_names << block if block_given?
              method_names.each { |mn| (hooks[h] ||= []) << mn }
            end
          end

        end

        private

        def run_hooks(hook)
          hooks = self.class.hooks[hook]
          return if hooks.nil?

          hooks.each { |h| Utils.cmd_call(self, h) }
        end

      end
    end

  end
end
