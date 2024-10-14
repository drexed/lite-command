# frozen_string_literal: true

class User

  attr_writer :first_name, :last_name, :email

  def first_name
    @first_name ||= "John"
  end

  def last_name
    @last_name ||= "Doe"
  end

  def email
    @email ||= "john.doe@example.com"
  end

  private

  def ssn
    "001-555-6789"
  end

end
