# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Attribute do
  subject(:command) { command_class.call(command_arguments) }
  let(:command_arguments) do
    { first_name: "John", last_name: "Doe" }
  end

  describe "#validations" do
    context "without options" do
      let(:command_class) do
        Class.new(BaseCommand) do
          attribute :first_name, :last_name, :ssn

          def call
            context.full_name = "#{first_name} #{last_name}"
          end
        end
      end

      it "returns successfully" do
        expect(command).to be_success
        expect(command.first_name).to eq("John")
        expect(command.last_name).to eq("Doe")
        expect(command.context.full_name).to eq("John Doe")
      end
    end

    context "with from option" do
      context "when attribute doesnt exists" do
        let(:command_class) do
          Class.new(BaseCommand) do
            attribute :first_name, :last_name, from: :fake

            def call
              context.full_name = "#{first_name} #{last_name}"
            end
          end
        end

        it "returns invalid" do
          expect(command).to be_invalid
          expect(command.reason).to eq("Invalid context attributes")
          expect(command.metadata).to eq(
            { fake: ["is not an attribute"] }
          )
        end
      end

      context "when attribute is not context" do
        let(:command_arguments) do
          { passport: double("passport", first_name: "John", last_name: "Doe") }
        end
        let(:command_class) do
          Class.new(BaseCommand) do
            attribute :passport
            attribute :first_name, :last_name, from: :passport

            def call
              context.full_name = "#{first_name} #{last_name}"
            end
          end
        end

        it "returns invalid" do
          expect(command).to be_success
          expect(command.first_name).to eq("John")
          expect(command.last_name).to eq("Doe")
          expect(command.context.full_name).to eq("John Doe")
        end
      end
    end

    context "with missing required option" do
      let(:command_arguments) do
        { first_name: "John" }
      end
      let(:command_class) do
        Class.new(BaseCommand) do
          attribute :first_name, :last_name, required: true

          def call
            context.full_name = "#{first_name} #{last_name}"
          end
        end
      end

      it "returns invalid" do
        expect(command).to be_invalid
        expect(command.reason).to eq("Invalid context attributes")
        expect(command.metadata).to eq(
          { context: ["last_name is required"] }
        )
      end
    end

    context "with invalid types option" do
      let(:command_arguments) do
        { first_name: "John", last_name: 123 }
      end
      let(:command_class) do
        Class.new(BaseCommand) do
          attribute :first_name, :last_name, types: [String, NilClass]

          def call
            context.full_name = "#{first_name} #{last_name}"
          end
        end
      end

      it "returns invalid" do
        expect(command).to be_invalid
        expect(command.reason).to eq("Invalid context attributes")
        expect(command.metadata).to eq(
          { context: ["last_name type invalid"] }
        )
      end
    end

    context "with filled option" do
      let(:command_arguments) do
        { first_name: "John", last_name: nil }
      end
      let(:command_class) do
        Class.new(BaseCommand) do
          attribute :first_name, :last_name, filled: true

          def call
            context.full_name = "#{first_name} #{last_name}"
          end
        end
      end

      it "returns invalid" do
        expect(command).to be_invalid
        expect(command.reason).to eq("Invalid context attributes")
        expect(command.metadata).to eq(
          { context: ["last_name must be filled"] }
        )
      end
    end
  end

end
