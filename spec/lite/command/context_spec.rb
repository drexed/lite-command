# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Context do
  subject(:context) { described_class.build(params) }

  let(:params) do
    { attr_one: "val_one" }
  end

  describe ".build" do
    it "returns same context" do
      other_context = described_class.build(context)
      expect(context.object_id).to eq(other_context.object_id)
    end
  end

  describe ".merge!" do
    it "adds new key value pair to the context" do
      context[:attr_two] = "val_two"
      expect(context.attr_two).to eq("val_two")
    end
  end
end
