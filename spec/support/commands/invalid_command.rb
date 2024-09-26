# frozen_string_literal: true

class InvalidCommand < Lite::Command::Base

  def call
    invalid!("Invalid command")
  end

end
