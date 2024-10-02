# frozen_string_literal: true

class NoopCommand < BaseCommand

  def call
    noop!("[!] command stopped due to noop")
  end

end
