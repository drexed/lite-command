# frozen_string_literal: true

class ValidationTokenCommand < ApplicationCommand

  def call
    if ctx.simulate_token_collision
      fail!("Validation token already exists")
    else
      context.validation_token = "123abc-456def"
    end
  end

end
