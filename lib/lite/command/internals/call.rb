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
      module Call

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

        def fault?(reason = nil)
          !success? && reason?(reason)
        end

        FAULTS.each do |f|
          # eg: noop? or failure?("idk")
          define_method(:"#{f}?") do |reason = nil|
            status == f && reason?(reason)
          end
        end

        private

        def fault(object, status, metadata)
          @status   = status
          @metadata = metadata

          @reason    ||= derive_reason_from(object)
          @metadata  ||= derive_metadata_from(object)
          @caused_by ||= derive_caused_by_from(object)
          @thrown_by ||= derive_thrown_by_from(object)
        end

        FAULTS.each do |f|
          # eg: invalid!("idk") or failure!(fault) or error!("idk", { error_key: "some.error" })
          define_method(:"#{f}!") do |object, metadata = nil|
            fault(object, f, metadata)
            raise runtime_fault(f.capitalize, object)
          end
        end

        alias fail! failure!

      end
    end

  end
end
