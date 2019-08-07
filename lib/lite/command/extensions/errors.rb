# frozen_string_literal: true

require 'lite/errors'

module Lite
  module Command
    module Extensions
      module Errors

        module ClassMethods

          def perform(*args)
            klass = call(*args)

            if klass.success?
              yield(klass.result, Lite::Command::Success, Lite::Command::Failure)
            else
              yield(klass.result, Lite::Command::Failure, Lite::Command::Success)
            end
          end

        end

        class << self

          def included(klass)
            klass.extend(ClassMethods)
          end

        end

        def errors
          @errors ||= Lite::Errors::Messages.new
        end

        def errored?
          !errors.empty?
        end

        def fail!
          raise Lite::Command::ValidationError
        end

        def failure?
          called? && errored?
        end

        def result!
          result if valid?
        end

        def status
          return :pending unless called?

          success? ? :success : :failure
        end

        def success?
          called? && !errored?
        end

        def validate!
          return true if success?

          fail!
        end

        alias valid? validate!

      end
    end
  end
end
