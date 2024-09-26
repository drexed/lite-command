# frozen_string_literal: true

class FailureCommand < Lite::Command::Base

  def call
    fail!("[!] command stopped due to failure")
  end

end
