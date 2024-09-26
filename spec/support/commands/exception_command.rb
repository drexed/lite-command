# frozen_string_literal: true

class ExceptionCommand < Lite::Command::Base

  def call
    raise "[!] command stopped due to exception"
  end

end
