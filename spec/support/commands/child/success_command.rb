# frozen_string_literal: true

module Child
  class SuccessCommand < BaseCommand

    def call
      # Do nothing, no fault = success
    end

  end
end
