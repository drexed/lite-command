# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Results do
  subject(:step) { CommandHelpers::ThrownStep.call }

  describe ".<<" do
    it "adds results and sorts them by trace order" do
      expect(step.results.map(&:class)).to eq(
        [
          CommandHelpers::ThrownStep,
          CommandHelpers::PassStep,
          CommandHelpers::NoopStep
        ]
      )
    end
  end
end
