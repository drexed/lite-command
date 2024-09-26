# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Base do
  subject(:command) { command_class.call }

  let(:command_class) { pass_command }
  let(:command_instance) { command_class.new }
  let(:pass_command) { CommandHelpers::PassCommand }
  let(:noop_command) { CommandHelpers::NoopCommand }
  let(:invalid_command) { CommandHelpers::InvalidCommand }
  let(:fail_command) { CommandHelpers::FailCommand }
  let(:error_command) { CommandHelpers::ErrorCommand }
  let(:exception_command) { CommandHelpers::ExceptionCommand }
  let(:thrown_command) { CommandHelpers::ThrownCommand }

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
      let(:command_class) { noop_command }

      it "runs after_execution callback method within the rescue block" do
        expect(command_instance).to receive(:after_execution).once
        command
      end

      it "runs on_noop callback method within the rescue block" do
        expect(command_instance).to receive(:on_noop).once
        command
      end

      it "raises a Lite::Command::Noop error" do
        expect { command_instance.execute! }.to raise_error(Lite::Command::Noop, "Nooped command")
      end

      it "raises a dynamic Lite::Command::Noop error" do
        allow(command_instance).to receive(:raise_dynamic_faults?).and_return(true)
        expect { command_instance.execute! }.to(raise_error do |error|
          expect(error.class.name).to eq("CommandHelpers::NoopCommand::Noop")
          expect(error.message).to eq("Nooped command")
        end)
      end

      it "returns a dnf state" do
        expect(command).to be_dnf
        expect(command.state).to eq(Lite::Command::DNF)
      end
    end

    context "when invalid" do
      let(:command_class) { invalid_command }

      it "runs after_execution callback method within the rescue block" do
        expect(command_instance).to receive(:after_execution).once
        command
      end

      it "runs on_invalid callback method within the rescue block" do
        expect(command_instance).to receive(:on_invalid).once
        command
      end

      it "raises a Lite::Command::Invalid error" do
        expect { command_instance.execute! }.to raise_error(Lite::Command::Invalid, "Invalid command")
      end

      it "raises a dynamic Lite::Command::Invalid error" do
        allow(command_instance).to receive(:raise_dynamic_faults?).and_return(true)
        expect { command_instance.execute! }.to(raise_error do |error|
          expect(error.class.name).to eq("CommandHelpers::InvalidCommand::Invalid")
          expect(error.message).to eq("Invalid command")
        end)
      end

      it "returns a dnf state" do
        expect(command).to be_dnf
        expect(command.state).to eq(Lite::Command::DNF)
      end
    end

    context "when failure" do
      let(:command_class) { fail_command }

      it "runs after_execution callback method within the rescue block" do
        expect(command_instance).to receive(:after_execution).once
        command
      end

      it "runs on_failure callback method within the rescue block" do
        expect(command_instance).to receive(:on_failure).once
        command
      end

      it "raises a Lite::Command::Failure error" do
        expect { command_instance.execute! }.to raise_error(Lite::Command::Failure, "Failed command")
      end

      it "raises a dynamic Lite::Command::Failure error" do
        allow(command_instance).to receive(:raise_dynamic_faults?).and_return(true)
        expect { command_instance.execute! }.to(raise_error do |error|
          expect(error.class.name).to eq("CommandHelpers::FailCommand::Failure")
          expect(error.message).to eq("Failed command")
        end)
      end

      it "returns a dnf state" do
        expect(command).to be_dnf
        expect(command.state).to eq(Lite::Command::DNF)
      end
    end

    context "when error" do
      let(:command_class) { error_command }

      it "runs after_execution callback method within the rescue block" do
        expect(command_instance).to receive(:after_execution).once
        command
      end

      it "runs on_error callback method within the rescue block" do
        expect(command_instance).to receive(:on_error).once
        command
      end

      it "raises a Lite::Command::Error error" do
        expect { command_instance.execute! }.to raise_error(Lite::Command::Error, "Errored command")
      end

      it "raises a dynamic Lite::Command::Error error" do
        allow(command_instance).to receive(:raise_dynamic_faults?).and_return(true)
        expect { command_instance.execute! }.to(raise_error do |error|
          expect(error.class.name).to eq("CommandHelpers::ErrorCommand::Error")
          expect(error.message).to eq("Errored command")
        end)
      end

      it "returns a dnf state" do
        expect(command).to be_dnf
        expect(command.state).to eq(Lite::Command::DNF)
      end
    end

    context "when fault" do
      let(:command_class) { thrown_command }

      it "returns executed" do
        expect(command).to be_executed
      end
    end

    context "with standard error" do
      let(:command_class) { exception_command }

      it "runs after_execution callback method within the rescue block" do
        expect(command_instance).to receive(:after_execution).once
        command
      end

      it "raises the true exception" do
        expect { command_instance.execute! }.to raise_error(RuntimeError, "Exception command")
      end

      it "raises the true exception when dynamic option is on" do
        allow(command_instance).to receive(:raise_dynamic_faults?).and_return(true)
        expect { command_instance.execute! }.to raise_error(RuntimeError, "Exception command")
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
      let(:command_class) { noop_command }

      it "returns a noop status" do
        expect(command).to be_noop
        expect(command).to be_faulter
        expect(command).to be_thrower
        expect(command).not_to be_thrown_fault
        expect(command.noop?("Nooped command")).to be(true)
        expect(command.noop?("Some reason")).to be(false)
        expect(command.status).to eq(Lite::Command::NOOP)
      end
    end

    context "when invalid" do
      let(:command_class) { invalid_command }

      it "returns a error status" do
        expect(command).to be_invalid
        expect(command).to be_faulter
        expect(command).to be_thrower
        expect(command).not_to be_thrown_fault
        expect(command.error?("Invalid command")).to be(true)
        expect(command.error?("Some reason")).to be(false)
        expect(command.status).to eq(Lite::Command::INVALID)
      end
    end

    context "when failure" do
      let(:command_class) { fail_command }

      it "returns a failure status" do
        expect(command).to be_failure
        expect(command).to be_faulter
        expect(command).to be_thrower
        expect(command).not_to be_thrown_fault
        expect(command.failure?("Failed command")).to be(true)
        expect(command.failure?("Some reason")).to be(false)
        expect(command.status).to eq(Lite::Command::FAILURE)
      end
    end

    context "when error" do
      let(:command_class) { error_command }

      it "returns a error status" do
        expect(command).to be_error
        expect(command).to be_faulter
        expect(command).to be_thrower
        expect(command).not_to be_thrown_fault
        expect(command.error?("Errored command")).to be(true)
        expect(command.error?("Some reason")).to be(false)
        expect(command.status).to eq(Lite::Command::ERROR)
      end
    end

    context "when exception" do
      let(:command_class) { exception_command }

      it "returns a error status" do
        expect(command).to be_error
        expect(command).to be_faulter
        expect(command).to be_thrower
        expect(command).not_to be_thrown_fault
        expect(command.error?("[RuntimeError] Exception command")).to be(true)
        expect(command.error?("Some reason")).to be(false)
        expect(command.status).to eq(Lite::Command::ERROR)
      end
    end

    context "when fault" do
      let(:command_class) { thrown_command }

      it "returns fault" do
        expect(command).to be_fault
        expect(command).not_to be_faulter
        expect(command).not_to be_thrower
        expect(command).to be_thrown_fault
        expect(command.fault?("Nooped command")).to be(true)
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
          "command" => "CommandHelpers::PassCommand",
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
          "command" => "CommandHelpers::PassCommand",
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
      let(:command_class) { noop_command }

      it "returns a noop status" do
        expect(command.results).not_to be_empty
        expect(command.result).to eq(Lite::Command::NOOP)
        expect(command.as_json).to eq(
          "index" => 1,
          "trace" => "1[1]",
          "command" => "CommandHelpers::NoopCommand",
          "result" => "NOOP",
          "state" => "DNF",
          "status" => "NOOP",
          "reason" => "Nooped command",
          "fault" => 1,
          "throw" => 1,
          "started_at" => "2021-05-11T18:20:00.000-04:00",
          "finished_at" => "2021-05-11T18:20:00.000-04:00",
          "runtime" => 0.0
        )
      end
    end

    context "when invalid" do
      let(:command_class) { invalid_command }

      it "returns a invalid status" do
        expect(command.results).not_to be_empty
        expect(command.result).to eq(Lite::Command::INVALID)
        expect(command.as_json).to eq(
          "command" => "CommandHelpers::InvalidCommand",
          "result" => "INVALID",
          "state" => "DNF",
          "status" => "INVALID",
          "reason" => "Invalid command",
          "started_at" => "2021-05-11T18:20:00.000-04:00",
          "finished_at" => "2021-05-11T18:20:00.000-04:00",
          "runtime" => 0.0
        )
      end
    end

    context "when failure" do
      let(:command_class) { fail_command }

      it "returns a failure status" do
        expect(command.results).not_to be_empty
        expect(command.result).to eq(Lite::Command::FAILURE)
        expect(command.as_json).to eq(
          "command" => "CommandHelpers::FailCommand",
          "result" => "FAILURE",
          "state" => "DNF",
          "status" => "FAILURE",
          "reason" => "Failed command",
          "started_at" => "2021-05-11T18:20:00.000-04:00",
          "finished_at" => "2021-05-11T18:20:00.000-04:00",
          "runtime" => 0.0
        )
      end
    end

    context "when error" do
      let(:command_class) { error_command }

      it "returns a error status" do
        expect(command.results).not_to be_empty
        expect(command.result).to eq(Lite::Command::ERROR)
        expect(command.as_json).to eq(
          "command" => "CommandHelpers::ErrorCommand",
          "result" => "ERROR",
          "state" => "DNF",
          "status" => "ERROR",
          "reason" => "Errored command",
          "started_at" => "2021-05-11T18:20:00.000-04:00",
          "finished_at" => "2021-05-11T18:20:00.000-04:00",
          "runtime" => 0.0
        )
      end
    end

    context "when exception" do
      let(:command_class) { exception_command }

      it "returns a error status" do
        expect(command.results).not_to be_empty
        expect(command.result).to eq(Lite::Command::ERROR)
        expect(command.as_json).to eq(
          "command" => "CommandHelpers::ExceptionCommand",
          "result" => "ERROR",
          "state" => "DNF",
          "status" => "ERROR",
          "reason" => "[RuntimeError] Exception command",
          "started_at" => "2021-05-11T18:20:00.000-04:00",
          "finished_at" => "2021-05-11T18:20:00.000-04:00",
          "runtime" => 0.0
        )
      end
    end

    context "when fault" do
      let(:command_class) { thrown_command }

      it "returns fault" do
        expect(command.results).not_to be_empty
        expect(command.result).to eq(Lite::Command::DNF)
        expect(command.as_json).to eq(
          "index" => 1,
          "trace" => "1[1]",
          "command" => "CommandHelpers::ThrownCommand",
          "result" => "DNF",
          "state" => "DNF",
          "status" => "NOOP",
          "reason" => "Nooped command",
          "fault" => 3,
          "throw" => 3,
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
