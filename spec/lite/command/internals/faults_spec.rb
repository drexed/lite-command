# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Internals::Faults do
  subject(:command) { command_class.call(command_arguments) }

  let(:command_arguments) do
    { first_name: "John", last_name: "Doe" }
  end

  describe "#validations" do
    context "with valid attributes" do
      let(:command_class) do
        Class.new(ApplicationCommand) do
          attribute :first_name, :last_name, :ssn

          def call
            context.full_name = "#{first_name} #{last_name}"
          end
        end
      end

      it "returns successfully" do
        expect(command).to be_success
      end
    end

    context "with invalid attributes" do
      let(:command_class) do
        Class.new(ApplicationCommand) do
          attribute :first_name, :last_name, from: :fake

          def call
            context.full_name = "#{first_name} #{last_name}"
          end
        end
      end

      it "returns invalid" do
        expect(command).to be_invalid
        expect(command.reason).to eq("Invalid context attributes")
        expect(command.metadata).to include(fake: ["is not defined or an attribute"])
      end
    end
  end

end
