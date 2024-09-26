# frozen_string_literal: true

class ExceptionCommand < Lite::Command::Base

  def call
    raise "Exception command"
  end

end
