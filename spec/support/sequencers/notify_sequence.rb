# frozen_string_literal: true

class NotifySequence < ApplicationSequence

  step Notifiers::EmailCommand
  step Notifiers::SmsCommand
  step Notifiers::PushCommand, if: proc { ctx.deliveries.include?("Sms") }
  step Notifiers::CarrierPigeonCommand, if: :summer?
  step Notifiers::SlackCommand, Notifiers::DiscordCommand

  private

  def summer?
    false
  end

end
