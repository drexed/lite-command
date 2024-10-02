# frozen_string_literal: true

module Child
  class SuccessCommand < BaseCommand

    def call
      ctx.result = 3**3
    end

  end
end
