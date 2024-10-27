# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Internals::Results do
  subject(:command) { EmailValidatorCommand.call(user:, simulate_unauthoized_token:) }

  let(:user) { User.new }
  let(:simulate_unauthoized_token) { false }

  before do
    [
      EmailValidatorCommand,
      ValidationTokenCommand
    ].each do |klass|
      allow_any_instance_of(klass).to receive(:freeze_execution_objects).and_return(true)
      allow_any_instance_of(klass).to receive(:cmd_id).and_return("018c2b95-b764-7615-a924-cc5b910ed1e5")
      allow_any_instance_of(klass).to receive(:runtime).and_return(0.0123)
    end
  end

  context "when noop" do
    context "without fault" do
      it "returns correct data" do
        expect(command.results.size).to eq(2)
        expect(command.to_hash).to eq(
          index: 1,
          cmd_id: "018c2b95-b764-7615-a924-cc5b910ed1e5",
          command: "EmailValidatorCommand",
          outcome: "success",
          state: "complete",
          status: "success",
          runtime: 0.0123
        )
      end
    end

    context "with fault" do
      let(:simulate_unauthoized_token) { true }

      it "returns correct data" do
        expect(command.results.size).to eq(3)
        expect(command.to_hash).to eq(
          index: 1,
          cmd_id: "018c2b95-b764-7615-a924-cc5b910ed1e5",
          command: "EmailValidatorCommand",
          outcome: "interrupted",
          state: "interrupted",
          status: "failure",
          reason: "Unauthorized token",
          caused_by: 3,
          thrown_by: 2,
          runtime: 0.0123
        )
      end
    end
  end
end
