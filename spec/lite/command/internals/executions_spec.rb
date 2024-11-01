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
            EmailValidatorCommand.after_initialize_hook
            EmailValidatorCommand.before_execution_hook
            EmailValidatorCommand.before_validation_hook
            EmailValidatorCommand.after_validation_hook
            EmailValidatorCommand.on_executing_hook
            ValidationTokenCommand.after_initialize_hook
            ValidationTokenCommand.before_execution_hook
            ValidationTokenCommand.before_validation_hook
            ValidationTokenCommand.after_validation_hook
            ValidationTokenCommand.on_executing_hook
            ValidationTokenCommand.on_success_hook
            ValidationTokenCommand.on_complete_hook
            ValidationTokenCommand.after_execution_hook
            EmailValidatorCommand.on_success_hook
            EmailValidatorCommand.on_complete_hook
            EmailValidatorCommand.after_execution_hook
          ]
        )
      end
    end

    context "with fault" do
      let(:simulate_token_collision) { true }

      it "calls correct hooks" do
        expect(command.context.hooks).to eq(
          %w[
            EmailValidatorCommand.after_initialize_hook
            EmailValidatorCommand.before_execution_hook
            EmailValidatorCommand.before_validation_hook
            EmailValidatorCommand.after_validation_hook
            EmailValidatorCommand.on_executing_hook
            ValidationTokenCommand.after_initialize_hook
            ValidationTokenCommand.before_execution_hook
            ValidationTokenCommand.before_validation_hook
            ValidationTokenCommand.after_validation_hook
            ValidationTokenCommand.on_executing_hook
            ValidationTokenCommand.on_failure_hook
            ValidationTokenCommand.on_interrupted_hook
            ValidationTokenCommand.after_execution_hook
            EmailValidatorCommand.on_failure_hook
            EmailValidatorCommand.on_interrupted_hook
            EmailValidatorCommand.after_execution_hook
          ]
        )
      end
    end
  end
end
