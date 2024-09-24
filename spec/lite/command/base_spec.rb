# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Base do
  subject(:step) { step_class.call }

  let(:step_class) { pass_step }
  let(:step_instance) { step_class.new }
  let(:pass_step) { CommandHelpers::PassStep }
  let(:noop_step) { CommandHelpers::NoopStep }
  let(:fail_step) { CommandHelpers::FailStep }
  let(:error_step) { CommandHelpers::ErrorStep }
  let(:thrown_step) { CommandHelpers::ThrownStep }

  before { travel_to(Time.parse("2021-05-11 17:20:00.000000000 -0500")) }
  after { travel_back }

  describe "#executable" do
    subject(:step) { step_instance.tap(&:execute) }

    context "when initialized" do
      it "returns a pending state" do
        expect(step_instance).to be_pending
        expect(step_instance.state).to eq(Lite::Command::PENDING)
      end
    end

    context "when executing" do
      it "runs before_execution and after_execution callback methods" do
        expect(step_instance).to receive(:before_execution).once
        expect(step_instance).to receive(:after_execution).once
        step
      end

      it "runs around_execution callback method" do
        expect(step_instance).to receive(:around_execution).once
        step
      end

      it "returns a executing state" do
        expect(step_instance).to receive(:executing!).once
        step
      end
    end

    context "when success" do
      it "returns a complete state" do
        expect(step).to be_complete
        expect(step.state).to eq(Lite::Command::COMPLETE)
      end
    end

    context "when noop" do
      let(:step_class) { noop_step }

      it "runs after_execution callback method within the rescue block" do
        expect(step_instance).to receive(:after_execution).once
        step
      end

      it "runs on_noop callback method within the rescue block" do
        expect(step_instance).to receive(:on_noop).once
        step
      end

      it "raises a Lite::Command::Noop error" do
        expect { step_instance.execute! }.to raise_error(Lite::Command::Noop, "Nooped step")
      end

      it "returns a dnf state" do
        expect(step).to be_dnf
        expect(step.state).to eq(Lite::Command::DNF)
      end
    end

    context "when failure" do
      let(:step_class) { fail_step }

      it "runs after_execution callback method within the rescue block" do
        expect(step_instance).to receive(:after_execution).once
        step
      end

      it "runs on_failure callback method within the rescue block" do
        expect(step_instance).to receive(:on_failure).once
        step
      end

      it "raises a Lite::Command::Failure error" do
        expect { step_instance.execute! }.to raise_error(Lite::Command::Failure, "Failed step")
      end

      it "returns a dnf state" do
        expect(step).to be_dnf
        expect(step.state).to eq(Lite::Command::DNF)
      end
    end

    context "when fault" do
      let(:step_class) { thrown_step }

      it "returns executed" do
        expect(step).to be_executed
      end
    end

    context "with standard error" do
      let(:step_class) { error_step }

      it "runs after_execution callback method within the rescue block" do
        expect(step_instance).to receive(:after_execution).once
        step
      end

      it "raises the true standard error error" do
        expect { step_instance.execute! }.to raise_error(RuntimeError, "Errored step")
      end

      it "runs on_error callback method within the rescue block" do
        expect(step_instance).to receive(:on_error).once
        step
      end

      it "returns a dnf state" do
        expect(step).to be_dnf
        expect(step.state).to eq(Lite::Command::DNF)
      end
    end
  end

  describe "#callable" do
    context "when initialized" do
      it "returns a success status" do
        expect(step_instance).to be_success
        expect(step_instance.status).to eq(Lite::Command::SUCCESS)
      end
    end

    context "when success" do
      it "returns a success status" do
        expect(step).to be_success
        expect(step.status).to eq(Lite::Command::SUCCESS)
      end
    end

    context "when noop" do
      let(:step_class) { noop_step }

      it "returns a noop status" do
        expect(step).to be_noop
        expect(step).to be_faulter
        expect(step).to be_thrower
        expect(step).not_to be_thrown_fault
        expect(step.noop?("Nooped step")).to be(true)
        expect(step.noop?("Some reason")).to be(false)
        expect(step.status).to eq(Lite::Command::NOOP)
      end
    end

    context "when failure" do
      let(:step_class) { fail_step }

      it "returns a failure status" do
        expect(step).to be_failure
        expect(step).to be_faulter
        expect(step).to be_thrower
        expect(step).not_to be_thrown_fault
        expect(step.failure?("Failed step")).to be(true)
        expect(step.failure?("Some reason")).to be(false)
        expect(step.status).to eq(Lite::Command::FAILURE)
      end
    end

    context "when error" do
      let(:step_class) { error_step }

      it "returns a failure status" do
        expect(step).to be_failure
        expect(step).to be_faulter
        expect(step).to be_thrower
        expect(step).not_to be_thrown_fault
        expect(step.failure?("[RuntimeError] Errored step")).to be(true)
        expect(step.failure?("Some reason")).to be(false)
        expect(step.status).to eq(Lite::Command::FAILURE)
      end
    end

    context "when fault" do
      let(:step_class) { thrown_step }

      it "returns fault" do
        expect(step).to be_fault
        expect(step).not_to be_faulter
        expect(step).not_to be_thrower
        expect(step).to be_thrown_fault
        expect(step.fault?("Nooped step")).to be(true)
        expect(step.fault?("Some reason")).to be(false)
        expect(step.faulter?).to be(false)
        expect(step.thrower?).to be(false)
      end
    end
  end

  describe "#resultable" do
    context "when initialized" do
      it "returns a success status" do
        expect(step_instance.results).to be_empty
        expect(step_instance.result).to eq(Lite::Command::PENDING)
        expect(step_instance.as_json).to eq(
          "step" => "CommandHelpers::PassStep",
          "result" => "PENDING",
          "state" => "PENDING",
          "status" => "SUCCESS"
        )
      end
    end

    context "when success" do
      it "returns a success status" do
        expect(step.results).not_to be_empty
        expect(step.result).to eq(Lite::Command::SUCCESS)
        expect(step.as_json).to eq(
          "index" => 1,
          "trace" => "1[1]",
          "step" => "CommandHelpers::PassStep",
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
      let(:step_class) { noop_step }

      it "returns a noop status" do
        expect(step.results).not_to be_empty
        expect(step.result).to eq(Lite::Command::NOOP)
        expect(step.as_json).to eq(
          "index" => 1,
          "trace" => "1[1]",
          "step" => "CommandHelpers::NoopStep",
          "result" => "NOOP",
          "state" => "DNF",
          "status" => "NOOP",
          "reason" => "Nooped step",
          "fault" => 1,
          "throw" => 1,
          "started_at" => "2021-05-11T18:20:00.000-04:00",
          "finished_at" => "2021-05-11T18:20:00.000-04:00",
          "runtime" => 0.0
        )
      end
    end

    context "when failure" do
      let(:step_class) { fail_step }

      it "returns a failure status" do
        expect(step.results).not_to be_empty
        expect(step.result).to eq(Lite::Command::FAILURE)
        expect(step.as_json).to eq(
          "step" => "CommandHelpers::FailStep",
          "result" => "FAILURE",
          "state" => "DNF",
          "status" => "FAILURE",
          "reason" => "Failed step",
          "started_at" => "2021-05-11T18:20:00.000-04:00",
          "finished_at" => "2021-05-11T18:20:00.000-04:00",
          "runtime" => 0.0
        )
      end
    end

    context "when fault" do
      let(:step_class) { thrown_step }

      it "returns fault" do
        expect(step.results).not_to be_empty
        expect(step.result).to eq(Lite::Command::DNF)
        expect(step.as_json).to eq(
          "index" => 1,
          "trace" => "1[1]",
          "step" => "CommandHelpers::ThrownStep",
          "result" => "DNF",
          "state" => "DNF",
          "status" => "NOOP",
          "reason" => "Nooped step",
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
        expect(step.to_h.keys).to include(:trace)
      end
    end

    context "when not enabled" do
      let(:step_class) { fail_step }

      it "removes the trace key" do
        expect(step.to_h.keys).not_to include(:trace)
      end
    end
  end
end
