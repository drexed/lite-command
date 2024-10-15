# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Internals::Calls do
  subject(:command) { EmailValidatorCommand.call(user:) }

  let(:user) { User.new }

  describe "#statuses" do
    context "when success" do
      it "returns correct data" do
        expect(command).to be_success
        expect(command).to be_ok
        expect(command).to have_attributes(
          status: Lite::Command::SUCCESS,
          reason: nil,
          metadata: nil
        )
      end
    end

    context "when noop" do
      let(:user) { User.new(email: "spy.master@cia.gov") }

      it "returns correct data" do
        expect(command).to be_noop
        expect(command).to be_fault
        expect(command).to be_ok
        expect(command).to have_attributes(
          status: Lite::Command::NOOP,
          reason: "Ummm, didn't see anything",
          metadata: nil
        )
      end
    end

    context "when invalid" do
      let(:user) { User.new(email: "jane.doe") }

      it "returns correct data" do
        expect(command).to be_invalid
        expect(command).to be_fault
        expect(command).to be_bad
        expect(command).to have_attributes(
          status: Lite::Command::INVALID,
          reason: "Invalid email format",
          metadata: { i18n: { errors: :invalid_email } }
        )
      end
    end

    context "when failure" do
      let(:user) { User.new(email: "john.doe@example.test") }

      it "returns correct data" do
        expect(command).to be_failure
        expect(command).to be_fault
        expect(command).to be_bad
        expect(command).to have_attributes(
          status: Lite::Command::FAILURE,
          reason: "Undeliverable TLD extension",
          metadata: nil
        )
      end
    end

    context "when error" do
      context "when uncaught" do
        let(:user) { User.new(email: "john.doe@example.wompwomp") }

        it "returns correct data" do
          expect(command).to be_error
          expect(command).to be_fault
          expect(command).to be_bad
          expect(command).to have_attributes(
            status: Lite::Command::ERROR,
            reason: "[ArgumentError] TLD extension doesn't exists",
            metadata: nil
          )
        end
      end

      context "when caught" do
        let(:user) { User.new(email: "john.doe+subaddy@example.com") }

        it "returns correct data" do
          expect(command).to be_error
          expect(command).to be_fault
          expect(command).to be_bad
          expect(command).to have_attributes(
            status: Lite::Command::ERROR,
            reason: "Womp womp, due to: Subaddressing is not allowed",
            metadata: nil
          )
        end
      end
    end
  end
end
