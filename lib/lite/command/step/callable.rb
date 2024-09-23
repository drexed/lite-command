# frozen_string_literal: true

module Lite
  module Command
    module Step
      module Callable

        extend ActiveSupport::Concern

        # Status represents the state of the callable code. If no fault
        # is thrown then a status of SUCCESS is returned even if `call`
        # has not been executed.
        STATUSES = [
          SUCCESS = "SUCCESS",
          NOOP = "NOOP",
          FAILURE = "FAILURE"
        ].freeze

        included { attr_reader :faulter, :thrower, :reason }

        class_methods do
          def call(context = {})
            new(context).tap(&:execute)
          end

          def call!(context = {})
            new(context).tap(&:execute!)
          end
        end

        def call
          raise NotImplementedError, "call method not defined in #{self.class} class"
        end

        def success?
          !fault?
        end

        def failure?(message = nil)
          status = @failure || false
          return status if message.nil?

          reason == message
        end

        def noop?(message = nil)
          status = @noop || false
          return status if message.nil?

          reason == message
        end

        def fault?(message = nil)
          failure?(message) || noop?(message)
        end

        def status
          return SUCCESS if success?
          return FAILURE if failure?

          NOOP
        end

        def faulter?
          faulter == self
        end

        def thrower?
          thrower == self
        end

        def thrown_fault?
          fault? && !faulter?
        end

        private

        def fault(obj)
          @faulter ||= obj.try(:faulter) || self
          @thrower ||= obj.try(:executed?) ? obj : (obj.try(:thrower) || faulter)
          @reason =
            if obj.respond_to?(:reason)
              obj.reason
            elsif obj.respond_to?(:message)
              "[#{obj.class.name}] #{obj.message}".chomp(".")
            else
              obj
            end
        end

        def noop(obj)
          fault(obj)
          @noop = true
        end

        def failure(obj)
          fault(obj)
          @failure = true
        end

        def noop!(obj)
          noop(obj)
          raise Lite::Command::Faults::Noop.new(faulter, self, reason)
        end

        def fail!(obj)
          failure(obj)
          raise Lite::Command::Faults::Failure.new(faulter, self, reason)
        end

        def throw!(step)
          case step.status
          when FAILURE then fail!(step)
          when NOOP then noop!(step)
          end
        end

      end
    end
  end
end
