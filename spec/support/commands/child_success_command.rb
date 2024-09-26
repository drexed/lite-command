# frozen_string_literal: true

class ChildNoopCommand < Lite::Command::Base

  def call
    noop!("[!] command stopped due to child noop")
  end

  private

  def trace_key
    :__child
  end

end
