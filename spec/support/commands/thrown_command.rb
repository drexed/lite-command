# frozen_string_literal: true

class ThrownCommand < Lite::Command::Base

  def call
    SuccessCommand.call(context)

    Child::SuccessCommand.call(context)
    Child::SuccessCommand.call(context)

    command = Child::NoopCommand.call(context)
    throw!(command)
  end

  private

  def trace_key
    :thrown
  end

end
