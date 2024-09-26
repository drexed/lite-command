# frozen_string_literal: true

class FailCommand < Lite::Command::Base

  def call
    fail!("Failed command")
  end

end
