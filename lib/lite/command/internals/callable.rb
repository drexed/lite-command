# frozen_string_literal: true

module Lite
  module Command

    STATUSES = [
      SUCCESS = "success",
      NOOP    = "noop",
      INVALID = "invalid",
      FAILURE = "failure",
      ERROR   = "error"
    ].freeze
    FAULTS = (STATUSES - [SUCCESS]).freeze

    module Internals
      module Callable

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods

          def call(context = {})
            new(context).tap(&:execute)
          end

          def call!(context = {})
            new(context).tap(&:execute!)
          end

        end

        def call
          raise NotImplementedError, "call method not defined in #{self.class}"
        end

        def status
          @status || SUCCESS
        end

        def success?
          status == SUCCESS
        end

        def fault?(str = nil)
          !success? && reason?(str)
        end

        FAULTS.each do |f|
          # eg: noop? or failure?("idk")
          define_method(:"#{f}?") do |str = nil|
            status == f && reason?(str)
          end
        end

        private

        def fault(object, type)
          @caused_by ||= derive_caused_by_from(object)
          @thrown_by ||= derive_thrown_by_from(object)
          @reason    ||= derive_reason_from(object)

          @status = type
        end

        FAULTS.each do |f|
          # eg: invalid!("idk") or failure!(fault)
          define_method(:"#{f}!") do |object|
            fault(object, f)
            raise runtime_fault(f.capitalize, object)
          end
        end

        alias fail! failure!

      end
    end

  end
end
