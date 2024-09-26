# frozen_string_literal: true

class ThrownCommand < Lite::Command::Base

  def call
    command = PassCommand.call(context)
    throw!(command)

    command = NoopCommand.call(context)
    throw!(command)
  end

  private

  def trace_key
    :thrown
  end

end
