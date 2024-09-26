# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Results do
  subject(:command) { ThrownCommand.call }

  describe ".<<" do
    it "adds results and sorts them by trace order" do
      expect(command.results.map(&:class)).to eq(
        [
          ThrownCommand,
          SuccessCommand,
          Child::SuccessCommand,
          Child::NoopCommand
        ]
      )
    end
  end
end
