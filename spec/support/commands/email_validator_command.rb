# frozen_string_literal: true

class EmailValidatorCommand < ApplicationCommand

  required :user
  required :email, from: :user
  optional :simulate_token_collision

  def call
    if !email.include?("@")
      invalid!("Invalid email format", i18n: { errors: :invalid_email })
    elsif email.include?("@cia.gov")
      noop!("Ummm, didn't see anything")
    elsif email.end_with?(".test")
      failure!("Undeliverable TLD extension")
    elsif email.end_with?(".wompwomp")
      raise ArgumentError, "TLD extension doesn't exists" # Uncaught exceptions
    elsif email.include?("+")
      raise NotImplementedError, "Subaddressing is not allowed" # Caught exceptions
    elsif validation_token.fault?
      throw!(validation_token)
    else
      context.validation_secret = "01001101011001100"
    end
  rescue NotImplementedError => e
    error!("Womp womp, due to: #{e.message}")
  end

  private

  def validation_token
    @validation_token ||= ValidationTokenCommand.call(context)
  end

end
