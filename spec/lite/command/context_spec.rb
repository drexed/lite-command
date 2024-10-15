# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Context do
  subject(:ctx) { Lite::Command::Context.build(params) }

  let(:params) do
    { attr_one: "val_one" }
  end

  describe ".build" do
    context "when context is not frozen" do
      it "returns same context" do
        other_ctx = Lite::Command::Context.build(ctx)

        expect(ctx.object_id).to eq(other_ctx.object_id)
      end
    end

    context "when context is frozen" do
      it "returns a new context" do
        other_ctx = Lite::Command::Context.build(ctx.freeze)

        expect(ctx.object_id).not_to eq(other_ctx.object_id)
      end
    end
  end

  describe ".merge!" do
    it "adds new key value pair to the context" do
      ctx.merge!(attr_two: "val_two", attr_three: "val_three")

      expect(ctx.to_h).to eq(
        {
          attr_one: "val_one",
          attr_two: "val_two",
          attr_three: "val_three"
        }
      )
    end
  end
end
