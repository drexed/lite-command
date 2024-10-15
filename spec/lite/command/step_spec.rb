# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Step do
  subject(:step) { Lite::Command::Step.new(ValidationTokenCommand, options) }

  let(:command) { EmailValidatorCommand.new(user:) }
  let(:user) { User.new }

  describe "#run" do
    context "without evaluation" do
      let(:options) { {} }

      it "returns true" do
        expect(step.run?(command)).to be(true)
      end
    end

    context "with if check" do
      let(:options) { { if: proc { 1 + 1 == 2 } } }

      it "returns true" do
        expect(step.run?(command)).to be(true)
      end
    end

    context "with unless check" do
      let(:options) { { unless: proc { 1 + 1 == 2 } } }

      it "returns false" do
        expect(step.run?(command)).to be(false)
      end
    end
  end
end
