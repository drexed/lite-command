# frozen_string_literal: true

class SuccessCommand < BaseCommand

  def call
    ctx.result = ctx.result.to_i + ctx.a.to_i + ctx.b.to_i
  end

end
