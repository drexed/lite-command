# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::AttributeValidator do
  subject(:validator) { Lite::Command::AttributeValidator.new(command) }

  let(:command) { EmailValidatorCommand.new(user:) }

  describe "#validations" do
    context "with valid arguments" do
      let(:user) { User.new }

      it "returns correct data" do
        expect(validator).to be_valid
        expect(validator.attributes).not_to be_empty
        expect(validator.errors).to eq({})
      end
    end

    context "with invalid arguments" do
      let(:user) { User.new(email: 123) }

      it "returns correct data" do
        expect(validator).not_to be_valid
        expect(validator.attributes).not_to be_empty
        expect(validator.errors).to eq({ user: ["email type invalid"] })
      end
    end
  end
end
