# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Internals::Executions do
  subject(:command) { EmailValidatorCommand.call(user:) }

  let(:user) { User.new }

  describe "#states" do
    context "when initialized" do
      it "returns pending" do
        command = EmailValidatorCommand.new(user:)

        expect(command).not_to be_executed
        expect(command).to be_pending
        expect(command).to have_attributes(state: Lite::Command::PENDING)
      end
    end

    context "without fault" do
      it "returns complete" do
        expect(command).to be_executed
        expect(command).to be_complete
        expect(command).to have_attributes(state: Lite::Command::COMPLETE)
      end
    end

    context "with fault" do
      let(:user) { User.new(email: "jane.doe") }

      it "returns interrupted" do
        expect(command).to be_executed
        expect(command).to be_interrupted
        expect(command).to have_attributes(state: Lite::Command::INTERRUPTED)
      end
    end
  end

  describe "#hooks" do
    it "returns parent and child hooks" do
      expect(command.context.hooks).to eq(
        %w[
          EmailValidatorCommand.on_pending
          EmailValidatorCommand.on_before_execution
          EmailValidatorCommand.on_executing
          EmailValidatorCommand.on_after_execution
          EmailValidatorCommand.on_success
          EmailValidatorCommand.on_complete
        ]
      )
    end
  end
end
