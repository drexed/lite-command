# frozen_string_literal: true

class InvalidCommand < Lite::Command::Base

  def call
    invalid!("[!] command stopped due to invalid")
  end

end
