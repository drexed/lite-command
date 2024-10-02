# frozen_string_literal: true

class ThrownCommand < BaseCommand

  def call
    SuccessCommand.call(context)

    Child::SuccessCommand.call(context)
    Child::SuccessCommand.call(context)

    command = Child::NoopCommand.call(context)
    throw!(command)
  end

end
