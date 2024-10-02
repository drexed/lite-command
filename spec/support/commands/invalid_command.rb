# frozen_string_literal: true

class InvalidCommand < BaseCommand

  def call
    invalid!("[!] command stopped due to invalid")
  end

end
