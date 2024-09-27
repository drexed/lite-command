# frozen_string_literal: true

class NoopCommand < Lite::Command::Base

  def call
    noop!("[!] command stopped due to noop")
  end

end
