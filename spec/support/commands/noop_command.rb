# frozen_string_literal: true

class NoopCommand < Lite::Command::Base

  def call
    noop!("Nooped command")
  end

  private

  def trace_key
    :noop
  end

end
