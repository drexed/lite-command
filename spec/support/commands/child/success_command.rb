# frozen_string_literal: true

module Child
  class SuccessCommand < Lite::Command::Base

    def call
      # Do nothing, no fault = success
    end

    private

    def trace_key
      :__child
    end

  end
end
