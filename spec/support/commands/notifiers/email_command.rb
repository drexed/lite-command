# frozen_string_literal: true

module Notifiers
  class EmailCommand < BaseCommand

    def call
      cmd = EmailValidatorCommand.call(context)
      cmd.fault? ? throw!(cmd) : deliver_by_channel
    end

  end
end
