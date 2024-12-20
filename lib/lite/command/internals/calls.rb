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
      module Calls

        def self.included(base)
          base.extend ClassMethods
          base.class_eval { attr_reader :reason, :metadata }
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

        def ok?(reason = nil)
          success? || noop?(reason)
        end

        def fault?(reason = nil)
          !success? && reason?(reason)
        end

        def bad?(reason = nil)
          !ok?(reason)
        end

        FAULTS.each do |f|
          # eg: noop? or failure?("idk")
          define_method(:"#{f}?") do |reason = nil|
            status == f && reason?(reason)
          end
        end

        private

        def reason?(str)
          str.nil? || str == reason
        end

        def fault(object, s, m, exception: nil) # rubocop:disable Naming/MethodParameterName
          return if s == SUCCESS || status != SUCCESS

          @status   = s
          @metadata = m

          fault_streamer = FaultStreamer.new(self, object)
          @reason    ||= fault_streamer.reason
          @metadata  ||= fault_streamer.metadata
          @caused_by ||= fault_streamer.caused_by
          @thrown_by ||= fault_streamer.thrown_by

          @command_exception  ||= fault_streamer.command_exception
          @original_exception ||= exception || command_exception
        end

        FAULTS.each do |f|
          # eg: invalid!("idk") or failure!(fault) or error!("idk", metadata: { error_key: "some.error" }, original_exception: err)
          define_method(:"#{f}!") do |object, metadata: nil, original_exception: nil|
            return unless success?

            fault(object, f, metadata, exception: original_exception)

            raise(command_exception)
          end
        end

        alias fail! failure!

      end
    end

  end
end
