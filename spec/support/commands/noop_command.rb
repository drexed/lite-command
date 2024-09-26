# frozen_string_literal: true

class NoopCommand < Lite::Command::Base

  def call
    noop!("Nooped command")
  end

  private

  def trace_key
    :pass # TODO: verify this is ok
  end

end
