# frozen_string_literal: true

module Child
  class NoopCommand < Lite::Command::Base

    def call
      noop!("[!] command stopped due to child noop")
    end

    private

    def trace_key
      :__child
    end

  end
end
