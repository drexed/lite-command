# frozen_string_literal: true

module Child
  class SuccessCommand < BaseCommand

    def call
      ctx.result = ctx.result.to_i + 99
    end

  end
end
