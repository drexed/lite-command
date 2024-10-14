# frozen_string_literal: true

class User

  attr_reader :first_name, :last_name, :email

  def initialize(opts = {})
    @first_name = opts.fetch(:first_name, "John")
    @last_name = opts.fetch(:last_name, "Doe")
    @email = opts.fetch(:email, "john.doe@example.com")
  end

  private

  def ssn
    "001-555-6789"
  end

end
