# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Sequence do
  subject(:sequence) { NotifySequence.call(user:, simulate_token_collision:) }

  let(:user) { User.new }
  let(:simulate_token_collision) { false }

  describe "#validations" do
    context "without fault" do
      let(:user) { User.new }

      it "returns correct data" do
        expect(sequence.context.deliveries).to eq(%w[Sms Email Push Slack Discord]) # Skips CarrierPigeonCommand
        expect(sequence).to have_attributes(
          status: Lite::Command::SUCCESS,
          reason: nil,
          metadata: nil
        )
      end
    end

    context "with fault" do
      let(:user) { User.new(email: "jane.doe") }

      it "returns correct data" do
        expect(sequence.context.deliveries).to eq(%w[Sms])
        expect(sequence).to have_attributes(
          status: Lite::Command::INVALID,
          reason: "Invalid email format",
          metadata: { i18n: { errors: :invalid_email } }
        )
      end
    end
  end
end
