# frozen_string_literal: true

module Child
  class SuccessCommand < Lite::Command::Base

    def call
      # Do nothing, no fault = success
    end

  end
end
