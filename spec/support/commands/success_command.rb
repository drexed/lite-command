# frozen_string_literal: true

class SuccessCommand < Lite::Command::Base

  def call
    # Do nothing, no fault = success
  end

  private

  def trace_key
    :success
  end

end
