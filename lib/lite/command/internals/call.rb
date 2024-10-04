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
            instance = send(:new, context)
            instance.send(:execute)
            instance
          end

          def call!(context = {})
            instance = send(:new, context)
            instance.send(:execute!)
            instance
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

          bubble = Lite::Command::Bubble.new(self, object)
          @reason    ||= bubble.reason
          @metadata  ||= bubble.metadata
          @caused_by ||= bubble.caused_by
          @thrown_by ||= bubble.thrown_by
        end

        FAULTS.each do |f|
          # eg: invalid!("idk") or failure!(fault) or error!("idk", { error_key: "some.error" })
          define_method(:"#{f}!") do |object, metadata = nil|
            fault(object, f, metadata)

            raise Lite::Command::Fault.build(f.capitalize, self, object, dynamic: raise_dynamic_faults?)
          end
        end

        alias fail! failure!

      end
    end

  end
end
