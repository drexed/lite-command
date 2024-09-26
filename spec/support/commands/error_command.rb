# frozen_string_literal: true

class ErrorCommand < Lite::Command::Base

  def call
    error!("Errored command")
  end

end
