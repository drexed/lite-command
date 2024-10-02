# frozen_string_literal: true

module Child
  class NoopCommand < BaseCommand

    def call
      noop!("[!] command stopped due to child noop")
    end

  end
end
