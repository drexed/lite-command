# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Fault do
  let(:command) { EmailValidatorCommand.call }

  describe "#types" do
    context "when not dynamic" do
      it "builds domainer specific faults" do
        expect(Lite::Command::Fault).to inherit_from(StandardError)
        expect(Lite::Command::Noop).to inherit_from(Lite::Command::Fault)
        expect(Lite::Command::Invalid).to inherit_from(Lite::Command::Fault)
        expect(Lite::Command::Failure).to inherit_from(Lite::Command::Fault)
        expect(Lite::Command::Error).to inherit_from(Lite::Command::Fault)
      end
    end

    context "when dynamic" do
      it "builds class specific faults" do
        expect(EmailValidatorCommand::Fault).to inherit_from(Lite::Command::Fault)
        expect(EmailValidatorCommand::Noop).to inherit_from(EmailValidatorCommand::Fault)
        expect(EmailValidatorCommand::Invalid).to inherit_from(EmailValidatorCommand::Fault)
        expect(EmailValidatorCommand::Failure).to inherit_from(EmailValidatorCommand::Fault)
        expect(EmailValidatorCommand::Error).to inherit_from(EmailValidatorCommand::Fault)
      end
    end
  end

  describe "#build" do
    let(:fault) { Lite::Command::Fault.build("Invalid", command, command, dynamic:) }

    context "when not dynamic" do
      let(:dynamic) { false }

      it "instantiates a matching Lite::Command based fault" do
        expect(fault.class).to eq(Lite::Command::Invalid)
      end
    end

    context "when dynamic" do
      let(:dynamic) { true }

      it "instantiates a matching class based fault" do
        expect(fault.class).to eq(EmailValidatorCommand::Invalid)
      end
    end
  end

  describe ".type" do
    let(:fault) do
      Lite::Command::Noop.new(
        reason: "Some reason",
        metadata: { a: 1 },
        caused_by: command,
        thrown_by: command
      )
    end

    it "returns the status type" do
      expect(fault.type).to eq("noop")
    end
  end

  # rubocop:disable Style/CaseEquality
  describe ".===" do
    let(:fault) do
      EmailValidatorCommand::Noop.new(
        reason: "Some reason",
        metadata: { a: 1 },
        caused_by: command,
        thrown_by: command
      )
    end

    {
      Lite::Command::Fault => true,
      Lite::Command::Noop => false,
      Lite::Command::Failure => false,
      EmailValidatorCommand::Fault => true,
      EmailValidatorCommand::Noop => true,
      EmailValidatorCommand::Failure => false
    }.each do |klass, bool|
      context "when #{klass} instance check" do
        it "returns #{bool}" do
          expect(fault === klass).to be(bool)
        end
      end

      context "when #{klass} class check" do
        it "returns #{bool}" do
          expect(fault.class === klass).to be(bool)
        end
      end

      context "when #{klass} case check" do
        it "returns #{bool}" do
          expect(
            case fault
            when klass then true
            else false
            end
          ).to be(bool)
        end
      end
    end
  end
  # rubocop:enable Style/CaseEquality
end
