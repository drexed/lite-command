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
end
