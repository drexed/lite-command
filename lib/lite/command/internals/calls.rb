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
          base.class_eval do
            attr_reader :reason, :metadata
          end
        end

        module ClassMethods

          def call(context = {})
            instance = send(:new, context)
            instance.validate
            instance.send(:execute)
            instance
          end

          def call!(context = {})
            instance = send(:new, context)
            instance.validate
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
          ![SUCCESS, NOOP].include?(status) && reason?(reason)
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

        def fault(object, status, metadata)
          @status   = status
          @metadata = metadata

          down_stream = Lite::Command::FaultStreamer.new(self, object)
          @reason    ||= down_stream.reason
          @metadata  ||= down_stream.metadata
          @caused_by ||= down_stream.caused_by
          @thrown_by ||= down_stream.thrown_by
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
