# frozen_string_literal: true

module Child
  class NoopCommand < BaseCommand

    def call
      noop!(
        "[!] command stopped due to child noop",
        i18n_key: "command.noop",
        errors: { name: ["doesn't start with an 'S'"] }
      )
    end

  end
end
