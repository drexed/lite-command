# frozen_string_literal: true

module Lite
  module Command

    # Status represents the state of the callable code. If no fault
    # is thrown then a status of SUCCESS is returned even if `call`
    # has not been executed.
    STATUSES = [
      SUCCESS = "SUCCESS",
      NOOP = "NOOP",
      INVALID = "INVALID",
      FAILURE = "FAILURE",
      ERROR = "ERROR"
    ].freeze

    module Step
      module Callable

        def self.included(base)
          base.extend ClassMethods
          base.class_eval do
            attr_reader :faulter, :thrower, :reason
          end
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

        def success?
          !fault?
        end

        def noop?(message = nil)
          status = @noop || false
          return status if message.nil?

          reason == message
        end

        def invalid?(message = nil)
          status = @invalid || false
          return status if message.nil?

          reason == message
        end

        def failure?(message = nil)
          status = @failure || false
          return status if message.nil?

          reason == message
        end

        def error?(message = nil)
          status = @error || false
          return status if message.nil?

          reason == message
        end

        def fault?(message = nil)
          noop?(message) ||
            invalid?(message) ||
            failure?(message) ||
            error?(message)
        end

        def status
          return SUCCESS if success?
          return NOOP if noop?
          return INVALID if invalid?
          return FAILURE if failure?

          ERROR
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

        def noop!(obj)
          noop(obj)
          raise Lite::Command::Noop.new(faulter, self, reason)
        end

        def on_noop(_error)
          # Define in your class to run code when a NOOP happens
        end

        def invalid(obj)
          fault(obj)
          @invalid = true
        end

        def invalid!(obj)
          invalid(obj)
          raise Lite::Command::Invalid.new(faulter, self, reason)
        end

        def on_invalid(_error)
          # Define in your class to run code when a NOOP happens
        end

        def failure(obj)
          fault(obj)
          @failure = true
        end

        def fail!(obj)
          failure(obj)
          raise Lite::Command::Failure.new(faulter, self, reason)
        end

        def on_failure(_error)
          # Define in your class to run code when a Failure happens
        end

        def error(obj)
          fault(obj)
          @error = true
        end

        def error!(obj)
          error(obj)
          raise Lite::Command::Error.new(faulter, self, reason)
        end

        def on_error(_error)
          # Define in your class to run code when a StandardError happens
        end

        def throw!(step)
          case step.status
          when NOOP then noop!(step)
          when INVALID then invalid!(step)
          when FAILURE then fail!(step)
          when ERROR then error!(step)
          end
        end

      end
    end

  end
end
