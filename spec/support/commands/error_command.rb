# frozen_string_literal: true

class ErrorCommand < Lite::Command::Base

  def call
    error!("[!] command stopped due to error")
  end

end
