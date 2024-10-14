# frozen_string_literal: true

module Notifiers
  class BaseCommand < ApplicationCommand

    def call
      deliver_by_channel
    end

    private

    def deliver_by_channel
      context.deliveries ||= []
      context.deliveries << self.class.name.chomp("Command").split("::").last
    end

  end
end
