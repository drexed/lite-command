# frozen_string_literal: true

class ThrownCommand < Lite::Command::Base

  def call
    ChildSuccessCommand.call(context)

    command = ChildNoopCommand.call(context)
    throw!(command)
  end

  private

  def trace_key
    :thrown
  end

end
