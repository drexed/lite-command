# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Base do
  subject(:command) { command_class.call(command_arguments) }

  let(:command_class) { SuccessCommand }
  let(:command_instance) { command_class.new(command_arguments) }
  let(:command_arguments) { {} }

  before do
    allow_any_instance_of(command_class).to receive(:cid).and_return("018c2b95-b764-7615-a924-cc5b910ed1e5")
    allow_any_instance_of(command_class).to receive(:runtime).and_return(0.0123)
  end

  describe "#context" do
    let(:command_class) { ContextCommand }

    context "with valid attributes" do
      let(:command_arguments) do
        {
          a: 1,
          storage: OpenStruct.new(b: 1, c: 1)
        }
      end

      it "returns successfully" do
        expect(command).to be_success
        expect(command.a).to eq(1)
        expect(command.ctx.result).to eq(3)
      end
    end

    context "with invalid from attributes" do
      let(:command_arguments) do
        {
          a: 1,
          storage: OpenStruct.new(b: 1, c: 1)
        }
      end

      it "returns invalid" do
        allow_any_instance_of(Lite::Command::Validator).to receive(:valid_from_attribute?).with(:context).and_return(true)
        allow_any_instance_of(Lite::Command::Validator).to receive(:valid_from_attribute?).with(:storage).and_return(false)

        expect(command).to be_invalid
        expect(command.reason).to eq("Invalid context attributes")
        expect(command.metadata).to eq(
          {
            storage: [
              "does not respond to b",
              "does not respond to c",
              "does not respond to f"
            ]
          }
        )
      end
    end

    context "with invalid type attributes" do
      let(:command_arguments) do
        {
          a: nil,
          storage: OpenStruct.new(b: 1, c: 1)
        }
      end

      it "returns invalid" do
        expect(command).to be_invalid
        expect(command.reason).to eq("Invalid context attributes")
        expect(command.metadata).to eq(
          {
            context: ["a type invalid"]
          }
        )
      end
    end

    context "with missing required attributes" do
      let(:command_arguments) { { a: 1 } }

      it "returns invalid" do
        # expect(command).to be_invalid
        expect(command.reason).to eq("Invalid context attributes")
        expect(command.metadata).to eq(
          {
            context: ["storage is required"],
            storage: ["b is required", "c is required"]
          }
        )
      end
    end

    context "with optional attributes" do
      let(:command_arguments) do
        {
          a: 1,
          storage: OpenStruct.new(b: 1, c: 1, f: 1),
          d: 1,
          e: 1
        }
      end

      it "returns successfully" do
        expect(command).to be_success
        expect(command.e).to eq(1)
        expect(command.ctx.result).to eq(6)
      end
    end
  end

  describe "#execute" do
    subject(:command) do
      command_instance.send(:execute)
      command_instance
    end

    context "when initialized" do
      it "returns a pending state" do
        expect(command_instance).to be_pending
        expect(command_instance.state).to eq(Lite::Command::PENDING)
      end
    end

    context "when executing" do
      it "runs before_execution and after_execution callback methods" do
        expect(command_instance).to receive(:before_execution).once
        expect(command_instance).to receive(:after_execution).once
        command
      end

      it "runs around_execution callback method" do
        expect(command_instance).to receive(:around_execution).once
        command
      end

      it "returns a executing state" do
        expect(command_instance).to receive(:executing!).once
        command
      end
    end

    context "when success" do
      it "runs callbacks in correct order" do
        expect(command.context.callbacks).to eq(
          %w[
            SuccessCommand.on_pending
            SuccessCommand.on_before_execution
            SuccessCommand.on_executing
            SuccessCommand.on_after_execution
            SuccessCommand.on_success
            SuccessCommand.on_complete
          ]
        )
      end

      it "returns a complete state" do
        expect(command).to be_complete
        expect(command.state).to eq(Lite::Command::COMPLETE)
      end
    end

    context "when noop" do
      let(:command_class) { NoopCommand }

      it "runs callbacks in correct order" do
        expect(command.context.callbacks).to eq(
          %w[
            NoopCommand.on_pending
            NoopCommand.on_before_execution
            NoopCommand.on_executing
            NoopCommand.on_after_execution
            NoopCommand.on_noop
            NoopCommand.on_interrupted
          ]
        )
      end

      it "raises a Lite::Command::Noop error" do
        expect { command_instance.send(:execute!) }.to raise_error(Lite::Command::Noop, "[!] command stopped due to noop")
      end

      it "raises a dynamic Lite::Command::Noop error" do
        allow(command_instance).to receive(:raise_dynamic_faults?).and_return(true)
        expect { command_instance.send(:execute!) }.to raise_error(NoopCommand::Noop, "[!] command stopped due to noop")
      end

      it "returns a interrupted state" do
        expect(command).to be_interrupted
        expect(command.state).to eq(Lite::Command::INTERRUPTED)
      end
    end

    context "when invalid" do
      let(:command_class) { InvalidCommand }

      it "runs callbacks in correct order" do
        expect(command.context.callbacks).to eq(
          %w[
            InvalidCommand.on_pending
            InvalidCommand.on_before_execution
            InvalidCommand.on_executing
            InvalidCommand.on_after_execution
            InvalidCommand.on_invalid
            InvalidCommand.on_interrupted
          ]
        )
      end

      it "raises a Lite::Command::Invalid error" do
        expect { command_instance.send(:execute!) }.to raise_error(Lite::Command::Invalid, "[!] command stopped due to invalid")
      end

      it "raises a dynamic Lite::Command::Invalid error" do
        allow(command_instance).to receive(:raise_dynamic_faults?).and_return(true)
        expect { command_instance.send(:execute!) }.to raise_error(InvalidCommand::Invalid, "[!] command stopped due to invalid")
      end

      it "returns a interrupted state" do
        expect(command).to be_interrupted
        expect(command.state).to eq(Lite::Command::INTERRUPTED)
      end
    end

    context "when failure" do
      let(:command_class) { FailureCommand }

      it "runs callbacks in correct order" do
        expect(command.context.callbacks).to eq(
          %w[
            FailureCommand.on_pending
            FailureCommand.on_before_execution
            FailureCommand.on_executing
            FailureCommand.on_after_execution
            FailureCommand.on_failure
            FailureCommand.on_interrupted
          ]
        )
      end

      it "raises a Lite::Command::Failure error" do
        expect { command_instance.send(:execute!) }.to raise_error(Lite::Command::Failure, "[!] command stopped due to failure")
      end

      it "raises a dynamic Lite::Command::Failure error" do
        allow(command_instance).to receive(:raise_dynamic_faults?).and_return(true)
        expect { command_instance.send(:execute!) }.to raise_error(FailureCommand::Failure, "[!] command stopped due to failure")
      end

      it "returns a interrupted state" do
        expect(command).to be_interrupted
        expect(command.state).to eq(Lite::Command::INTERRUPTED)
      end
    end

    context "when error" do
      let(:command_class) { ErrorCommand }

      it "runs callbacks in correct order" do
        expect(command.context.callbacks).to eq(
          %w[
            ErrorCommand.on_pending
            ErrorCommand.on_before_execution
            ErrorCommand.on_executing
            ErrorCommand.on_after_execution
            ErrorCommand.on_error
            ErrorCommand.on_interrupted
          ]
        )
      end

      it "raises a Lite::Command::Error error" do
        expect { command_instance.send(:execute!) }.to raise_error(Lite::Command::Error, "[!] command stopped due to error")
      end

      it "raises a dynamic Lite::Command::Error error" do
        allow(command_instance).to receive(:raise_dynamic_faults?).and_return(true)
        expect { command_instance.send(:execute!) }.to raise_error(ErrorCommand::Error, "[!] command stopped due to error")
      end

      it "returns a interrupted state" do
        expect(command).to be_interrupted
        expect(command.state).to eq(Lite::Command::INTERRUPTED)
      end
    end

    context "with standard error" do
      let(:command_class) { ExceptionCommand }

      it "runs callbacks in correct order" do
        expect(command.context.callbacks).to eq(
          %w[
            ExceptionCommand.on_pending
            ExceptionCommand.on_before_execution
            ExceptionCommand.on_executing
            ExceptionCommand.on_after_execution
            ExceptionCommand.on_error
            ExceptionCommand.on_interrupted
          ]
        )
      end

      it "raises the true exception" do
        expect { command_instance.send(:execute!) }.to raise_error(RuntimeError, "[!] command stopped due to exception")
      end

      it "raises the true exception when dynamic option is on" do
        allow(command_instance).to receive(:raise_dynamic_faults?).and_return(true)
        expect { command_instance.send(:execute!) }.to raise_error(RuntimeError, "[!] command stopped due to exception")
      end

      it "returns a interrupted state" do
        expect(command).to be_interrupted
        expect(command.state).to eq(Lite::Command::INTERRUPTED)
      end
    end

    context "when thrown" do
      let(:command_class) { ThrownCommand }

      it "returns executed" do
        expect(command).to be_executed
      end

      it "runs callbacks in correct order" do
        expect(command.context.callbacks).to eq(
          %w[
            ThrownCommand.on_pending
            ThrownCommand.on_before_execution
            ThrownCommand.on_executing
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
            Child::SuccessCommand.on_pending
            Child::SuccessCommand.on_before_execution
            Child::SuccessCommand.on_executing
            Child::SuccessCommand.on_after_execution
            Child::SuccessCommand.on_success
            Child::SuccessCommand.on_complete
            Child::NoopCommand.on_pending
            Child::NoopCommand.on_before_execution
            Child::NoopCommand.on_executing
            Child::NoopCommand.on_after_execution
            Child::NoopCommand.on_noop
            Child::NoopCommand.on_interrupted
            ThrownCommand.on_after_execution
            ThrownCommand.on_noop
            ThrownCommand.on_interrupted
          ]
        )
      end

      it "raises a Lite::Command::Error error" do
        expect { command_instance.send(:execute!) }.to raise_error(Lite::Command::Noop, "[!] command stopped due to child noop")
      end

      it "raises a dynamic Lite::Command::Error error" do
        allow(command_instance).to receive(:raise_dynamic_faults?).and_return(true)
        expect { command_instance.send(:execute!) }.to raise_error(ThrownCommand::Noop, "[!] command stopped due to child noop")
      end

      it "returns a interrupted state" do
        expect(command).to be_interrupted
        expect(command.state).to eq(Lite::Command::INTERRUPTED)
      end
    end

    context "when executed" do
      it "freezes the command and its context" do
        allow_any_instance_of(command_class).to receive(:freeze_execution_objects).and_call_original

        expect(command).to be_frozen
        expect(command.context).to be_frozen
      end
    end
  end

  describe "#call" do
    context "when initialized" do
      it "returns a success status" do
        expect(command_instance).to be_success
        expect(command_instance.status).to eq(Lite::Command::SUCCESS)
      end
    end

    context "when success" do
      it "returns a success status" do
        expect(command).to be_success
        expect(command.status).to eq(Lite::Command::SUCCESS)
      end
    end

    context "when noop" do
      let(:command_class) { NoopCommand }

      it "returns a noop status" do
        expect(command).to be_noop
        expect(command).to be_caused_fault
        expect(command).to be_threw_fault
        expect(command).not_to be_thrown
        expect(command.noop?("[!] command stopped due to noop")).to be(true)
        expect(command.noop?("Some reason")).to be(false)
        expect(command.status).to eq(Lite::Command::NOOP)
      end
    end

    context "when invalid" do
      let(:command_class) { InvalidCommand }

      it "returns a error status" do
        expect(command).to be_invalid
        expect(command).to be_caused_fault
        expect(command).to be_threw_fault
        expect(command).not_to be_thrown
        expect(command.invalid?("[!] command stopped due to invalid")).to be(true)
        expect(command.invalid?("Some reason")).to be(false)
        expect(command.status).to eq(Lite::Command::INVALID)
      end
    end

    context "when failure" do
      let(:command_class) { FailureCommand }

      it "returns a failure status" do
        expect(command).to be_failure
        expect(command).to be_caused_fault
        expect(command).to be_threw_fault
        expect(command).not_to be_thrown
        expect(command.failure?("[!] command stopped due to failure")).to be(true)
        expect(command.failure?("Some reason")).to be(false)
        expect(command.status).to eq(Lite::Command::FAILURE)
      end
    end

    context "when error" do
      let(:command_class) { ErrorCommand }

      it "returns a error status" do
        expect(command).to be_error
        expect(command).to be_caused_fault
        expect(command).to be_threw_fault
        expect(command).not_to be_thrown
        expect(command.error?("[!] command stopped due to error")).to be(true)
        expect(command.error?("Some reason")).to be(false)
        expect(command.status).to eq(Lite::Command::ERROR)
      end
    end

    context "when exception" do
      let(:command_class) { ExceptionCommand }

      it "returns a error status" do
        expect(command).to be_error
        expect(command).to be_caused_fault
        expect(command).to be_threw_fault
        expect(command).not_to be_thrown
        expect(command.error?("[RuntimeError] [!] command stopped due to exception")).to be(true)
        expect(command.error?("Some reason")).to be(false)
        expect(command.status).to eq(Lite::Command::ERROR)
      end
    end

    context "when thrown" do
      let(:command_class) { ThrownCommand }

      it "returns fault" do
        expect(command).to be_fault
        expect(command).not_to be_caused_fault
        expect(command).not_to be_threw_fault
        expect(command).to be_thrown
        expect(command.fault?("[!] command stopped due to child noop")).to be(true)
        expect(command.fault?("Some reason")).to be(false)
      end
    end
  end

  describe "#result" do
    context "when initialized" do
      it "returns a success status" do
        expect(command_instance.results).to be_empty
        expect(command_instance.to_hash).to eq(
          index: 0,
          cid: "018c2b95-b764-7615-a924-cc5b910ed1e5",
          command: "SuccessCommand",
          outcome: "pending",
          state: "pending",
          status: "success",
          runtime: 0.0123
        )
      end
    end

    context "when success" do
      it "returns a success status" do
        expect(command.results).not_to be_empty
        expect(command.to_hash).to eq(
          index: 1,
          cid: "018c2b95-b764-7615-a924-cc5b910ed1e5",
          command: "SuccessCommand",
          outcome: "success",
          state: "complete",
          status: "success",
          runtime: 0.0123
        )
      end
    end

    context "when noop" do
      let(:command_class) { NoopCommand }

      it "returns a noop status" do
        expect(command.results).not_to be_empty
        expect(command.to_hash).to eq(
          index: 1,
          cid: "018c2b95-b764-7615-a924-cc5b910ed1e5",
          command: "NoopCommand",
          outcome: "noop",
          state: "interrupted",
          status: "noop",
          reason: "[!] command stopped due to noop",
          caused_by: 1,
          thrown_by: 1,
          runtime: 0.0123
        )
      end
    end

    context "when invalid" do
      let(:command_class) { InvalidCommand }

      it "returns a invalid status" do
        expect(command.results).not_to be_empty
        expect(command.to_hash).to eq(
          index: 1,
          cid: "018c2b95-b764-7615-a924-cc5b910ed1e5",
          command: "InvalidCommand",
          outcome: "invalid",
          state: "interrupted",
          status: "invalid",
          reason: "[!] command stopped due to invalid",
          caused_by: 1,
          thrown_by: 1,
          runtime: 0.0123
        )
      end
    end

    context "when failure" do
      let(:command_class) { FailureCommand }

      it "returns a failure status" do
        expect(command.results).not_to be_empty
        expect(command.to_hash).to eq(
          index: 1,
          cid: "018c2b95-b764-7615-a924-cc5b910ed1e5",
          command: "FailureCommand",
          outcome: "failure",
          state: "interrupted",
          status: "failure",
          reason: "[!] command stopped due to failure",
          metadata: {
            errors: { name: ["is too short"] },
            i18n_key: "command.failure"
          },
          caused_by: 1,
          thrown_by: 1,
          runtime: 0.0123
        )
      end
    end

    context "when error" do
      let(:command_class) { ErrorCommand }

      it "returns a error status" do
        expect(command.results).not_to be_empty
        expect(command.to_hash).to eq(
          index: 1,
          cid: "018c2b95-b764-7615-a924-cc5b910ed1e5",
          command: "ErrorCommand",
          outcome: "error",
          state: "interrupted",
          status: "error",
          reason: "[!] command stopped due to error",
          caused_by: 1,
          thrown_by: 1,
          runtime: 0.0123
        )
      end
    end

    context "when exception" do
      let(:command_class) { ExceptionCommand }

      it "returns a error status" do
        expect(command.results).not_to be_empty
        expect(command.to_hash).to eq(
          index: 1,
          cid: "018c2b95-b764-7615-a924-cc5b910ed1e5",
          command: "ExceptionCommand",
          outcome: "error",
          state: "interrupted",
          status: "error",
          reason: "[RuntimeError] [!] command stopped due to exception",
          caused_by: 1,
          thrown_by: 1,
          runtime: 0.0123
        )
      end
    end

    context "when thrown" do
      let(:command_class) { ThrownCommand }

      it "returns childs error status" do
        expect(command.results).not_to be_empty
        expect(command.to_hash).to eq(
          index: 1,
          cid: "018c2b95-b764-7615-a924-cc5b910ed1e5",
          command: "ThrownCommand",
          outcome: "interrupted",
          state: "interrupted",
          status: "noop",
          reason: "[!] command stopped due to child noop",
          metadata: {
            errors: { name: ["doesn't start with an 'S'"] },
            i18n_key: "command.noop"
          },
          caused_by: 5,
          thrown_by: 5,
          runtime: 0.0123
        )
      end
    end
  end
end
