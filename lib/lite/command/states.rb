# frozen_string_literal: true

module Lite
  module Command

    class Success

      class << self

        def call
          yield
        end

      end

    end

    class Failure

      class << self

        def call
          # Do nothing
        end

      end

    end

  end
end
