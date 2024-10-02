# frozen_string_literal: true

class FailureCommand < BaseCommand

  def call
    fail!("[!] command stopped due to failure")
  end

end
