# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Internals::Executions do
  subject(:command) { EmailValidatorCommand.call(user:, simulate_token_collision:) }

  let(:user) { User.new }
  let(:simulate_token_collision) { false }

  describe "#states" do
    context "when initialized" do
      it "returns correct data" do
        command = EmailValidatorCommand.new(user:)

        expect(command).not_to be_executed
        expect(command).to be_pending
        expect(command).to have_attributes(state: Lite::Command::PENDING)
      end
    end

    context "without fault" do
      it "returns correct data" do
        expect(command).to be_executed
        expect(command).not_to be_caused_fault
        expect(command).not_to be_threw_fault
        expect(command).not_to be_thrown
        expect(command).to be_complete
        expect(command).to have_attributes(state: Lite::Command::COMPLETE)
        expect(command.context).to have_attributes(
          validation_token: "123abc-456def",
          validation_secret: "01001101011001100"
        )
      end
    end

    context "with causing fault" do
      let(:user) { User.new(email: "jane.doe") }

      it "returns correct data" do
        expect(command).to be_executed
        expect(command).to be_caused_fault
        expect(command).to be_threw_fault
        expect(command).not_to be_thrown
        expect(command).to be_interrupted
        expect(command).to have_attributes(state: Lite::Command::INTERRUPTED)
        expect(command.context.to_h.keys).not_to include(
          :validation_token,
          :validation_secret
        )
      end
    end

    context "with thrown fault" do
      let(:simulate_token_collision) { true }

      it "returns correct data" do
        expect(command).to be_executed
        expect(command).not_to be_caused_fault
        expect(command).not_to be_threw_fault
        expect(command).to be_thrown
        expect(command).to be_interrupted
        expect(command).to have_attributes(state: Lite::Command::INTERRUPTED)
        expect(command.context.to_h.keys).not_to include(
          :validation_token,
          :validation_secret
        )
      end
    end
  end

  describe "#hooks" do
    context "without fault" do
      it "calls correct hooks" do
        expect(command.context.hooks).to eq(
          %w[
            EmailValidatorCommand.on_pending
            EmailValidatorCommand.on_before_validation
            EmailValidatorCommand.on_before_execution
            EmailValidatorCommand.on_executing
            ValidationTokenCommand.on_pending
            ValidationTokenCommand.on_before_validation
            ValidationTokenCommand.on_before_execution
            ValidationTokenCommand.on_executing
            ValidationTokenCommand.on_after_execution
            ValidationTokenCommand.on_success
            ValidationTokenCommand.on_complete
            EmailValidatorCommand.on_after_execution
            EmailValidatorCommand.on_success
            EmailValidatorCommand.on_complete
          ]
        )
      end
    end

    context "with fault" do
      let(:simulate_token_collision) { true }

      it "calls correct hooks" do
        expect(command.context.hooks).to eq(
          %w[
            EmailValidatorCommand.on_pending
            EmailValidatorCommand.on_before_validation
            EmailValidatorCommand.on_before_execution
            EmailValidatorCommand.on_executing
            ValidationTokenCommand.on_pending
            ValidationTokenCommand.on_before_validation
            ValidationTokenCommand.on_before_execution
            ValidationTokenCommand.on_executing
            ValidationTokenCommand.on_after_execution
            ValidationTokenCommand.on_failure
            ValidationTokenCommand.on_interrupted
            EmailValidatorCommand.on_after_execution
            EmailValidatorCommand.on_failure
            EmailValidatorCommand.on_interrupted
          ]
        )
      end
    end
  end
end
