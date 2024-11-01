# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Utils do
  let(:user) { User.new }

  describe ".pretty_exception" do
    it "returns true" do
      value = Lite::Command::Utils.pretty_exception(RuntimeError.new("womp womp"))

      expect(value).to eq("[RuntimeError] womp womp")
    end
  end

  describe ".descendant_of?" do
    context "when is descendant" do
      it "returns true" do
        value = Lite::Command::Utils.descendant_of?(Lite::Command::Error, StandardError)

        expect(value).to be(true)
      end
    end

    context "when not descendant" do
      it "returns false" do
        value = Lite::Command::Utils.descendant_of?(Lite::Command::Error, RuntimeError)

        expect(value).to be(false)
      end
    end
  end

  describe ".cmd_try" do
    context "when method public exists" do
      it "returns value" do
        value = Lite::Command::Utils.cmd_try(user, :first_name)

        expect(value).to eq("John")
      end
    end

    context "when method private exists" do
      it "returns value" do
        value = Lite::Command::Utils.cmd_try(user, :ssn)

        expect(value).to eq("001-555-6789")
      end
    end

    context "when method missing" do
      it "returns nil" do
        value = Lite::Command::Utils.cmd_try(user, :gender)

        expect(value).to be_nil
      end
    end
  end

  describe ".cmd_call" do
    context "when symbol" do
      it "returns method value" do
        value = Lite::Command::Utils.cmd_call(user, :first_name)

        expect(value).to eq("John")
      end
    end

    context "when string" do
      it "returns method value" do
        value = Lite::Command::Utils.cmd_call(user, "first_name")

        expect(value).to eq("John")
      end
    end

    context "when proc" do
      it "returns block value" do
        value = Lite::Command::Utils.cmd_call(user, proc { 1 + 1 })

        expect(value).to eq(2)
      end
    end

    context "when unknown" do
      it "returns argument value" do
        value = Lite::Command::Utils.cmd_call(user, 123)

        expect(value).to eq(123)
      end
    end
  end

  describe ".cmd_eval" do
    context "with if and unless option" do
      it "returns true" do
        value = Lite::Command::Utils.cmd_eval(user, { if: proc { 1 + 2 == 3 }, unless: proc { 1 + 1 == 3 } })

        expect(value).to be(true)
      end
    end

    context "with if option" do
      it "returns false" do
        value = Lite::Command::Utils.cmd_eval(user, { if: proc { 1 + 2 == 0 } })

        expect(value).to be(false)
      end
    end

    context "with unless option" do
      it "returns false" do
        value = Lite::Command::Utils.cmd_eval(user, { unless: proc { 1 + 2 == 3 } })

        expect(value).to be(false)
      end
    end

    context "with default option" do
      it "returns false" do
        value = Lite::Command::Utils.cmd_eval(user, { default: false })

        expect(value).to be(false)
      end
    end

    context "with empty options" do
      it "returns true" do
        value = Lite::Command::Utils.cmd_eval(user, {})

        expect(value).to be(true)
      end
    end
  end

end
