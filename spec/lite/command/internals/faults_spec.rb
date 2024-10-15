# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Internals::Faults do
  subject(:command) { EmailValidatorCommand.call(user:, simulate_token_collision:) }

  let(:user) { User.new }
  let(:simulate_token_collision) { false }

  describe "#statuses" do
    context "when success" do
      it "returns correct data" do
        expect(command).to be_success
        expect(command.caused_by).to be_nil
        expect(command).not_to be_caused_fault
        expect(command.thrown_by).to be_nil
        expect(command).not_to be_threw_fault
        expect(command).not_to be_thrown
      end
    end

    context "when caused fault" do
      let(:user) { User.new(email: "spy.master@cia.gov") }

      it "returns correct data" do
        expect(command).to be_noop
        expect(command.caused_by).to eq(command)
        expect(command).to be_caused_fault
        expect(command.thrown_by).to eq(command)
        expect(command).to be_threw_fault
        expect(command).not_to be_thrown
      end
    end

    context "when thrown fault" do
      let(:simulate_token_collision) { true }

      it "returns correct data" do
        expect(command).to be_failure
        expect(command.caused_by).to be_a(ValidationTokenCommand)
        expect(command).not_to be_caused_fault
        expect(command.thrown_by).to be_a(ValidationTokenCommand)
        expect(command).not_to be_threw_fault
        expect(command).to be_thrown
      end
    end
  end

  describe "#raise_dynamic_faults" do
    let(:user) { User.new(email: "jane.doe") }

    context "when enabled" do
      it "raises a EmailValidatorCommand::Invalid exception" do
        expect { EmailValidatorCommand.call!(user:) }.to raise_error(
          EmailValidatorCommand::Invalid,
          "Invalid email format"
        )
      end
    end

    context "when disabled" do
      it "raises a Lite::Command::Invalid exception" do
        allow_any_instance_of(EmailValidatorCommand).to receive(:freeze_execution_objects).and_return(true)
        allow_any_instance_of(EmailValidatorCommand).to receive(:raise_dynamic_faults?).and_return(false)

        expect { EmailValidatorCommand.call!(user:) }.to raise_error(
          Lite::Command::Invalid,
          "Invalid email format"
        )
      end
    end
  end
end
