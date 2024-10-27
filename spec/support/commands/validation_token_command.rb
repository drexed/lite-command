# frozen_string_literal: true

class ValidationTokenCommand < ApplicationCommand

  optional :simulate_unauthoized_token, :simulate_token_collision

  def call
    if simulate_unauthoized_token
      AuthorizeTokenCommand.call!(ctx)
    elsif simulate_token_collision
      fail!("Validation token already exists")
    else
      context.validation_token = "123abc-456def"
    end
  end

end
