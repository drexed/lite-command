# frozen_string_literal: true

class ExceptionCommand < BaseCommand

  def call
    raise "[!] command stopped due to exception"
  end

end
