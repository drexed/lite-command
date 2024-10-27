# frozen_string_literal: true

class AuthorizeTokenCommand < ApplicationCommand

  def call
    return unless ctx.simulate_unauthoized_token

    fail!("Unauthorized token")
  end

end
