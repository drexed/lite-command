# frozen_string_literal: true

class SuccessCommand < BaseCommand

  def call
    ctx.result = 2**2
  end

end
