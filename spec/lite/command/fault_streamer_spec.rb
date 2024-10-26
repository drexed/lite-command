# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::FaultStreamer do
  subject(:streamer) { Lite::Command::FaultStreamer.new(command, object) }

  let(:command) { EmailValidatorCommand.call(user:, simulate_token_collision:) }
  let(:error) { ArgumentError.new("invalid args provided") }
  let(:string) { "Womp womp, something happened" }

  let(:user) { User.new }
  let(:simulate_token_collision) { false }

  describe "#stream" do
    context "when object is a command" do
      let(:object) { command }

      context "when caused fault" do
        let(:user) { User.new(email: "jane.doe") }

        it "returns correct data" do
          expect(streamer.reason).to eq("Invalid email format")
          expect(streamer.metadata).to eq(command.metadata)
          expect(streamer.caused_by).to be_a(EmailValidatorCommand)
          expect(streamer.thrown_by).to be_a(EmailValidatorCommand)
          expect(streamer.fault_exception).to be_a(EmailValidatorCommand::Invalid)
        end
      end

      context "when thrown fault" do
        let(:simulate_token_collision) { true }

        it "returns correct data" do
          allow_any_instance_of(ValidationTokenCommand).to receive(:freeze_execution_objects).and_return(true)
          allow_any_instance_of(ValidationTokenCommand).to receive(:metadata).and_return([1, 2, 3])

          expect(streamer.reason).to eq("Validation token already exists")
          expect(streamer.metadata).to eq([1, 2, 3])
          expect(streamer.caused_by).to be_a(ValidationTokenCommand)
          expect(streamer.thrown_by).to be_a(EmailValidatorCommand)
          expect(streamer.fault_exception).to be_a(EmailValidatorCommand::Failure)
        end
      end
    end

    context "when object is a standard error" do
      let(:object) { error }

      it "returns correct data" do
        expect(streamer.reason).to eq("[ArgumentError] invalid args provided")
        expect(streamer.metadata).to eq(command.metadata)
        expect(streamer.caused_by).to be_a(EmailValidatorCommand)
        expect(streamer.thrown_by).to be_nil
        expect(streamer.fault_exception).to be_nil
      end
    end

    context "when object is a string" do
      let(:object) { string }

      it "returns correct data" do
        expect(streamer.reason).to eq(object)
        expect(streamer.metadata).to eq(command.metadata)
        expect(streamer.caused_by).to be_a(EmailValidatorCommand)
        expect(streamer.thrown_by).to be_nil
        expect(streamer.fault_exception).to be_nil
      end
    end
  end

end
