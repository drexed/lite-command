# frozen_string_literal: true

class FailureCommand < BaseCommand

  def call
    fail!(
      "[!] command stopped due to failure",
      i18n_key: "command.failure",
      errors: { name: ["is too short"] }
    )
  end

end
