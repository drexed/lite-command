# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Sequence do
  subject(:sequence) { sequence_class.call(sequence_arguments) }

  let(:sequence_class) { Sequences::SuccessSequence }
  let(:sequence_instance) { sequence_class.new(sequence_arguments) }
  let(:sequence_arguments) { { a: 1, b: 1 } }

  before do
    allow_any_instance_of(sequence_class).to receive(:cmd_id).and_return("018c2b95-b764-7615-a924-cc5b910ed1e5")
    allow_any_instance_of(sequence_class).to receive(:runtime).and_return(0.0123)
  end

  describe "#execute" do
    context "when success" do
      it "runs callbacks in correct order" do
        expect(sequence).to be_complete
        expect(sequence.state).to eq(Lite::Command::COMPLETE)
        expect(sequence).to be_success
        expect(sequence.status).to eq(Lite::Command::SUCCESS)
        expect(sequence.context.result).to eq(103)
        expect(sequence.context.callbacks).to eq(
          %w[
            Sequences::SuccessSequence.on_pending
            Sequences::SuccessSequence.on_before_execution
            Sequences::SuccessSequence.on_executing
            SuccessCommand.on_pending
            SuccessCommand.on_before_execution
            SuccessCommand.on_executing
            SuccessCommand.on_after_execution
            SuccessCommand.on_success
            SuccessCommand.on_complete
            NoopCommand.on_pending
            NoopCommand.on_before_execution
            NoopCommand.on_executing
            NoopCommand.on_after_execution
            NoopCommand.on_noop
            NoopCommand.on_interrupted
            SuccessCommand.on_pending
            SuccessCommand.on_before_execution
            SuccessCommand.on_executing
            SuccessCommand.on_after_execution
            SuccessCommand.on_success
            SuccessCommand.on_complete
            Child::SuccessCommand.on_pending
            Child::SuccessCommand.on_before_execution
            Child::SuccessCommand.on_executing
            Child::SuccessCommand.on_after_execution
            Child::SuccessCommand.on_success
            Child::SuccessCommand.on_complete
            Sequences::SuccessSequence.on_after_execution
            Sequences::SuccessSequence.on_success
            Sequences::SuccessSequence.on_complete
          ]
        )
        expect(sequence.results).not_to be_empty
        expect(sequence.to_hash).to eq(
          index: 1,
          cmd_id: "018c2b95-b764-7615-a924-cc5b910ed1e5",
          command: "Sequences::SuccessSequence",
          outcome: "success",
          state: "complete",
          status: "success",
          runtime: 0.0123
        )
      end
    end

    context "when failure" do
      let(:sequence_class) { Sequences::FailureSequence }

      it "returns a failure status" do
        expect(sequence).to be_failure
        expect(sequence.status).to eq(Lite::Command::FAILURE)
        expect(sequence).to be_interrupted
        expect(sequence.state).to eq(Lite::Command::INTERRUPTED)
        expect(sequence).not_to be_caused_fault
        expect(sequence).not_to be_threw_fault
        expect(sequence).to be_thrown
        expect(sequence.failure?("[!] command stopped due to failure")).to be(true)
        expect(sequence.failure?("Some reason")).to be(false)
        expect(sequence.context.result).to eq(2)
        expect(sequence.context.callbacks).to eq(
          %w[
            Sequences::FailureSequence.on_pending
            Sequences::FailureSequence.on_before_execution
            Sequences::FailureSequence.on_executing
            SuccessCommand.on_pending
            SuccessCommand.on_before_execution
            SuccessCommand.on_executing
            SuccessCommand.on_after_execution
            SuccessCommand.on_success
            SuccessCommand.on_complete
            FailureCommand.on_pending
            FailureCommand.on_before_execution
            FailureCommand.on_executing
            FailureCommand.on_after_execution
            FailureCommand.on_failure
            FailureCommand.on_interrupted
            Sequences::FailureSequence.on_after_execution
            Sequences::FailureSequence.on_failure
            Sequences::FailureSequence.on_interrupted
          ]
        )
        expect(sequence.results).not_to be_empty
        expect(sequence.to_hash).to eq(
          index: 1,
          cmd_id: "018c2b95-b764-7615-a924-cc5b910ed1e5",
          command: "Sequences::FailureSequence",
          outcome: "interrupted",
          state: "interrupted",
          status: "failure",
          reason: "[!] command stopped due to failure",
          metadata: { i18n_key: "command.failure", errors: { name: ["is too short"] } },
          caused_by: 3,
          thrown_by: 3,
          runtime: 0.0123
        )
      end
    end
  end

end
