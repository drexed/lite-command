# frozen_string_literal: true

class EmailValidatorCommand < ApplicationCommand

  attribute :user, required: { reject_nil: true }, type: User
  attribute :email, required: { reject_empty: true }, type: String, from: :user

  def call
    if !email.include?("@")
      invalid!("Invalid email format", i18n: { errors: :invalid_email })
    elsif email.include?("@cia.gov")
      noop!("Ummm, didn't see anything")
    elsif email.end_with?(".test")
      failure!("Undeliverable TLD extension")
    elsif email.end_with?(".wompwomp")
      # Testing uncaught exceptions
      raise NotImplementedError, "TLD extension doesn't exists"
    elsif email.start_with?("+")
      raise ArgumentError, "Email must not start with + sign"
    else
      context.validation_token = "123abc"
    end
  rescue NotImplementedError => e
    error!("Womp womp, lost connection: #{e.message}")
  end

end
