# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Base do
  subject(:command) { command_class.call }

  let(:command_class) { SuccessCommand }
  let(:command_instance) { command_class.new }

  before { travel_to(Time.parse("2021-05-11 17:20:00.000000000 -0500")) }
  after { travel_back }

  describe "#executable" do
    subject(:command) { command_instance.tap(&:execute) }

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
      it "returns a complete state" do
        expect(command).to be_complete
        expect(command.state).to eq(Lite::Command::COMPLETE)
      end
    end

    context "when noop" do
      let(:command_class) { NoopCommand }

      it "runs after_execution callback method within the rescue block" do
        expect(command_instance).to receive(:after_execution).once
        command
      end

      it "runs on_noop callback method within the rescue block" do
        expect(command_instance).to receive(:on_noop).once
        command
      end

      it "raises a Lite::Command::Noop error" do
        expect { command_instance.execute! }.to raise_error(Lite::Command::Noop, "[!] command stopped due to noop")
      end

      it "raises a dynamic Lite::Command::Noop error" do
        allow(command_instance).to receive(:raise_dynamic_faults?).and_return(true)
        expect { command_instance.execute! }.to raise_error(NoopCommand::Noop, "[!] command stopped due to noop")
      end

      it "returns a dnf state" do
        expect(command).to be_dnf
        expect(command.state).to eq(Lite::Command::DNF)
      end
    end

    context "when invalid" do
      let(:command_class) { InvalidCommand }

      it "runs after_execution callback method within the rescue block" do
        expect(command_instance).to receive(:after_execution).once
        command
      end

      it "runs on_invalid callback method within the rescue block" do
        expect(command_instance).to receive(:on_invalid).once
        command
      end

      it "raises a Lite::Command::Invalid error" do
        expect { command_instance.execute! }.to raise_error(Lite::Command::Invalid, "[!] command stopped due to invalid")
      end

      it "raises a dynamic Lite::Command::Invalid error" do
        allow(command_instance).to receive(:raise_dynamic_faults?).and_return(true)
        expect { command_instance.execute! }.to raise_error(InvalidCommand::Invalid, "[!] command stopped due to invalid")
      end

      it "returns a dnf state" do
        expect(command).to be_dnf
        expect(command.state).to eq(Lite::Command::DNF)
      end
    end

    context "when failure" do
      let(:command_class) { FailureCommand }

      it "runs after_execution callback method within the rescue block" do
        expect(command_instance).to receive(:after_execution).once
        command
      end

      it "runs on_failure callback method within the rescue block" do
        expect(command_instance).to receive(:on_failure).once
        command
      end

      it "raises a Lite::Command::Failure error" do
        expect { command_instance.execute! }.to raise_error(Lite::Command::Failure, "[!] command stopped due to failure")
      end

      it "raises a dynamic Lite::Command::Failure error" do
        allow(command_instance).to receive(:raise_dynamic_faults?).and_return(true)
        expect { command_instance.execute! }.to raise_error(FailureCommand::Failure, "[!] command stopped due to failure")
      end

      it "returns a dnf state" do
        expect(command).to be_dnf
        expect(command.state).to eq(Lite::Command::DNF)
      end
    end

    context "when error" do
      let(:command_class) { ErrorCommand }

      it "runs after_execution callback method within the rescue block" do
        expect(command_instance).to receive(:after_execution).once
        command
      end

      it "runs on_error callback method within the rescue block" do
        expect(command_instance).to receive(:on_error).once
        command
      end

      it "raises a Lite::Command::Error error" do
        expect { command_instance.execute! }.to raise_error(Lite::Command::Error, "[!] command stopped due to error")
      end

      it "raises a dynamic Lite::Command::Error error" do
        allow(command_instance).to receive(:raise_dynamic_faults?).and_return(true)
        expect { command_instance.execute! }.to raise_error(ErrorCommand::Error, "[!] command stopped due to error")
      end

      it "returns a dnf state" do
        expect(command).to be_dnf
        expect(command.state).to eq(Lite::Command::DNF)
      end
    end

    context "when thrown" do
      let(:command_class) { ThrownCommand }

      it "returns executed" do
        expect(command).to be_executed
      end

      it "runs after_execution callback method within the rescue block" do
        expect(command_instance).to receive(:after_execution).once
        command
      end

      it "runs on_noop callback method within the rescue block" do
        expect(command_instance).to receive(:on_noop).once
        command
      end

      it "raises a Lite::Command::Error error" do
        expect { command_instance.execute! }.to raise_error(Lite::Command::Noop, "[!] command stopped due to child noop")
      end

      it "raises a dynamic Lite::Command::Error error" do
        allow(command_instance).to receive(:raise_dynamic_faults?).and_return(true)
        expect { command_instance.execute! }.to raise_error(ThrownCommand::Noop, "[!] command stopped due to child noop")
      end

      it "returns a dnf state" do
        expect(command).to be_dnf
        expect(command.state).to eq(Lite::Command::DNF)
      end
    end

    context "with standard error" do
      let(:command_class) { ExceptionCommand }

      it "runs after_execution callback method within the rescue block" do
        expect(command_instance).to receive(:after_execution).once
        command
      end

      it "raises the true exception" do
        expect { command_instance.execute! }.to raise_error(RuntimeError, "[!] command stopped due to exception")
      end

      it "raises the true exception when dynamic option is on" do
        allow(command_instance).to receive(:raise_dynamic_faults?).and_return(true)
        expect { command_instance.execute! }.to raise_error(RuntimeError, "[!] command stopped due to exception")
      end

      it "runs on_error callback method within the rescue block" do
        expect(command_instance).to receive(:on_error).once
        command
      end

      it "returns a dnf state" do
        expect(command).to be_dnf
        expect(command.state).to eq(Lite::Command::DNF)
      end
    end
  end

  describe "#callable" do
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
        expect(command).to be_faulter
        expect(command).to be_thrower
        expect(command).not_to be_thrown_fault
        expect(command.noop?("[!] command stopped due to noop")).to be(true)
        expect(command.noop?("Some reason")).to be(false)
        expect(command.status).to eq(Lite::Command::NOOP)
      end
    end

    context "when invalid" do
      let(:command_class) { InvalidCommand }

      it "returns a error status" do
        expect(command).to be_invalid
        expect(command).to be_faulter
        expect(command).to be_thrower
        expect(command).not_to be_thrown_fault
        expect(command.error?("[!] command stopped due to invalid")).to be(true)
        expect(command.error?("Some reason")).to be(false)
        expect(command.status).to eq(Lite::Command::INVALID)
      end
    end

    context "when failure" do
      let(:command_class) { FailureCommand }

      it "returns a failure status" do
        expect(command).to be_failure
        expect(command).to be_faulter
        expect(command).to be_thrower
        expect(command).not_to be_thrown_fault
        expect(command.failure?("[!] command stopped due to failure")).to be(true)
        expect(command.failure?("Some reason")).to be(false)
        expect(command.status).to eq(Lite::Command::FAILURE)
      end
    end

    context "when error" do
      let(:command_class) { ErrorCommand }

      it "returns a error status" do
        expect(command).to be_error
        expect(command).to be_faulter
        expect(command).to be_thrower
        expect(command).not_to be_thrown_fault
        expect(command.error?("[!] command stopped due to error")).to be(true)
        expect(command.error?("Some reason")).to be(false)
        expect(command.status).to eq(Lite::Command::ERROR)
      end
    end

    context "when exception" do
      let(:command_class) { ExceptionCommand }

      it "returns a error status" do
        expect(command).to be_error
        expect(command).to be_faulter
        expect(command).to be_thrower
        expect(command).not_to be_thrown_fault
        expect(command.error?("[RuntimeError] [!] command stopped due to exception")).to be(true)
        expect(command.error?("Some reason")).to be(false)
        expect(command.status).to eq(Lite::Command::ERROR)
      end
    end

    context "when thrown" do
      let(:command_class) { ThrownCommand }

      it "returns fault" do
        expect(command).to be_fault
        expect(command).not_to be_faulter
        expect(command).not_to be_thrower
        expect(command).to be_thrown_fault
        expect(command.fault?("[!] command stopped due to child noop")).to be(true)
        expect(command.fault?("Some reason")).to be(false)
        expect(command.faulter?).to be(false)
        expect(command.thrower?).to be(false)
      end
    end
  end

  describe "#resultable" do
    context "when initialized" do
      it "returns a success status" do
        expect(command_instance.results).to be_empty
        expect(command_instance.result).to eq(Lite::Command::PENDING)
        expect(command_instance.as_json).to eq(
          "command" => "SuccessCommand",
          "result" => "PENDING",
          "state" => "PENDING",
          "status" => "SUCCESS"
        )
      end
    end

    context "when success" do
      it "returns a success status" do
        expect(command.results).not_to be_empty
        expect(command.result).to eq(Lite::Command::SUCCESS)
        expect(command.as_json).to eq(
          "index" => 1,
          "trace" => "1[1]",
          "command" => "SuccessCommand",
          "result" => "SUCCESS",
          "state" => "COMPLETE",
          "status" => "SUCCESS",
          "started_at" => "2021-05-11T18:20:00.000-04:00",
          "finished_at" => "2021-05-11T18:20:00.000-04:00",
          "runtime" => 0.0
        )
      end
    end

    context "when noop" do
      let(:command_class) { NoopCommand }

      it "returns a noop status" do
        expect(command.results).not_to be_empty
        expect(command.result).to eq(Lite::Command::NOOP)
        expect(command.as_json).to eq(
          "index" => 1,
          "trace" => "1[1]",
          "command" => "NoopCommand",
          "result" => "NOOP",
          "state" => "DNF",
          "status" => "NOOP",
          "reason" => "[!] command stopped due to noop",
          "fault" => 1,
          "throw" => 1,
          "started_at" => "2021-05-11T18:20:00.000-04:00",
          "finished_at" => "2021-05-11T18:20:00.000-04:00",
          "runtime" => 0.0
        )
      end
    end

    context "when invalid" do
      let(:command_class) { InvalidCommand }

      it "returns a invalid status" do
        expect(command.results).not_to be_empty
        expect(command.result).to eq(Lite::Command::INVALID)
        expect(command.as_json).to eq(
          "command" => "InvalidCommand",
          "result" => "INVALID",
          "state" => "DNF",
          "status" => "INVALID",
          "reason" => "[!] command stopped due to invalid",
          "started_at" => "2021-05-11T18:20:00.000-04:00",
          "finished_at" => "2021-05-11T18:20:00.000-04:00",
          "runtime" => 0.0
        )
      end
    end

    context "when failure" do
      let(:command_class) { FailureCommand }

      it "returns a failure status" do
        expect(command.results).not_to be_empty
        expect(command.result).to eq(Lite::Command::FAILURE)
        expect(command.as_json).to eq(
          "command" => "FailureCommand",
          "result" => "FAILURE",
          "state" => "DNF",
          "status" => "FAILURE",
          "reason" => "[!] command stopped due to failure",
          "started_at" => "2021-05-11T18:20:00.000-04:00",
          "finished_at" => "2021-05-11T18:20:00.000-04:00",
          "runtime" => 0.0
        )
      end
    end

    context "when error" do
      let(:command_class) { ErrorCommand }

      it "returns a error status" do
        expect(command.results).not_to be_empty
        expect(command.result).to eq(Lite::Command::ERROR)
        expect(command.as_json).to eq(
          "command" => "ErrorCommand",
          "result" => "ERROR",
          "state" => "DNF",
          "status" => "ERROR",
          "reason" => "[!] command stopped due to error",
          "started_at" => "2021-05-11T18:20:00.000-04:00",
          "finished_at" => "2021-05-11T18:20:00.000-04:00",
          "runtime" => 0.0
        )
      end
    end

    context "when exception" do
      let(:command_class) { ExceptionCommand }

      it "returns a error status" do
        expect(command.results).not_to be_empty
        expect(command.result).to eq(Lite::Command::ERROR)
        expect(command.as_json).to eq(
          "command" => "ExceptionCommand",
          "result" => "ERROR",
          "state" => "DNF",
          "status" => "ERROR",
          "reason" => "[RuntimeError] [!] command stopped due to exception",
          "started_at" => "2021-05-11T18:20:00.000-04:00",
          "finished_at" => "2021-05-11T18:20:00.000-04:00",
          "runtime" => 0.0
        )
      end
    end

    context "when thrown" do
      let(:command_class) { ThrownCommand }

      it "returns childs error status" do
        expect(command.results).not_to be_empty
        expect(command.result).to eq(Lite::Command::DNF)
        expect(command.as_json).to eq(
          "index" => 1,
          "trace" => "1[1]",
          "command" => "ThrownCommand",
          "result" => "DNF",
          "state" => "DNF",
          "status" => "NOOP",
          "reason" => "[!] command stopped due to child noop",
          "fault" => 4,
          "throw" => 4,
          "started_at" => "2021-05-11T18:20:00.000-04:00",
          "finished_at" => "2021-05-11T18:20:00.000-04:00",
          "runtime" => 0.0
        )
      end
    end
  end

  describe "#traceable" do
    context "when enabled" do
      it "includes the trace key" do
        expect(command.to_h.keys).to include(:trace)
      end
    end

    context "when not enabled" do
      it "removes the trace key" do
        allow_any_instance_of(command_class).to receive(:trace_key).and_return(nil)
        expect(command.to_h.keys).not_to include(:trace)
      end
    end
  end
end
