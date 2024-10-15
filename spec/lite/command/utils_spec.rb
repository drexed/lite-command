# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Utils do
  let(:user) { User.new }

  describe ".try" do
    context "when method public exists" do
      it "returns value" do
        value = Lite::Command::Utils.try(user, :first_name)

        expect(value).to eq("John")
      end
    end

    context "when method private exists" do
      it "returns value" do
        value = Lite::Command::Utils.try(user, :ssn)

        expect(value).to eq("001-555-6789")
      end
    end

    context "when method missing" do
      it "returns nil" do
        value = Lite::Command::Utils.try(user, :gender)

        expect(value).to be_nil
      end
    end
  end

  describe ".call" do
    context "when symbol" do
      it "returns method value" do
        value = Lite::Command::Utils.call(user, :first_name)

        expect(value).to eq("John")
      end
    end

    context "when string" do
      it "returns method value" do
        value = Lite::Command::Utils.call(user, "first_name")

        expect(value).to eq("John")
      end
    end

    context "when proc" do
      it "returns block value" do
        value = Lite::Command::Utils.call(user, proc { 1 + 1 })

        expect(value).to eq(2)
      end
    end

    context "when unknown" do
      it "returns argument value" do
        value = Lite::Command::Utils.call(user, 123)

        expect(value).to eq(123)
      end
    end
  end

end