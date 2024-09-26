# frozen_string_literal: true

class PassCommand < Lite::Command::Base

  def call
    # Do nothing, success
  end

  private

  def trace_key
    :pass
  end

end
