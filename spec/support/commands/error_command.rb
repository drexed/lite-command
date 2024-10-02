# frozen_string_literal: true

class ErrorCommand < BaseCommand

  def call
    error!("[!] command stopped due to error")
  end

end
