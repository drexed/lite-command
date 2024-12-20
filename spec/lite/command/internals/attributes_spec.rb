# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Internals::Attributes do
  subject(:command) { command_class.call(args) }

  let(:args) do
    { first_name: "John", last_name: "Doe" }
  end

  describe "#validations" do
    context "with valid attributes" do
      let(:command_class) do
        Class.new(AnonymousCommand) do
          required :first_name, :last_name
          optional :ssn
        end
      end

      it "returns successfully" do
        expect(command).to be_success
        expect(command.reason).to be_nil
        expect(command.metadata).to be_nil
        expect(command).to have_attributes(
          first_name: "John",
          last_name: "Doe",
          ssn: nil
        )
      end
    end

    context "with valid delegation" do
      let(:args) do
        { user: User.new }
      end
      let(:command_class) do
        Class.new(AnonymousCommand) do
          required :user
          required :first_name, :last_name, from: :user
          required :passport, if: :ssn_missing?
          optional :ssn, from: :user

          private

          def ssn_missing?
            context.user.send(:ssn).nil?
          end
        end
      end

      it "returns success" do
        expect(command).to be_success
        expect(command.reason).to be_nil
        expect(command.metadata).to be_nil
        expect(command).to have_attributes(
          first_name: "John",
          last_name: "Doe",
          ssn: "001-555-6789"
        )
      end
    end

    context "with invalid delegation" do
      let(:command_class) do
        Class.new(AnonymousCommand) do
          required :first_name, :last_name, from: :fake
          optional :ssn, from: :fake
        end
      end

      it "returns invalid" do
        expect(command).to be_invalid
        expect(command.reason).to eq("Fake is an undefined argument")
        expect(command.metadata).to include(fake: ["is an undefined argument"])
      end
    end

    context "with failed validations" do
      let(:args) do
        { user: User.new }
      end
      let(:command_class) do
        Class.new(AnonymousCommand) do
          required :user
          required :first_name, :last_name, from: :user
          optional :ssn, from: :user

          validates :first_name, :ssn, length: { maximum: 1 }
          validate :validate_dummy_ssn

          private

          def validate_dummy_ssn
            return if ssn.nil? || !ssn.starts_with?("001")

            errors.add(:ssn, :invalid, message: "is a dummy")
          end
        end
      end

      it "returns invalid" do
        expect(command).to be_invalid
        expect(command.reason).to eq("First name is too long (maximum is 1 character). Ssn is too long (maximum is 1 character). Ssn is a dummy")
        expect(command.metadata).to include(
          first_name: ["is too long (maximum is 1 character)"],
          ssn: ["is too long (maximum is 1 character)", "is a dummy"]
        )
      end
    end
  end

end
