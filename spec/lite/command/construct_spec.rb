# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Construct do
  subject(:construct) { described_class.init(context) }

  let(:context) do
    { attr_1: "val_1" }
  end

  describe ".init" do
    it "creates a new open struct" do
      expect(construct.class).to eq(described_class)
      expect(construct.attr_1).to eq("val_1")
    end
  end

  describe ".build" do
    subject(:construct) { described_class.build(context) }

    it "returns same construct" do
      other_construct = described_class.build(construct)
      expect(construct.object_id).to eq(other_construct.object_id)
    end
  end

  describe ".merge!" do
    it "adds new key value pair to the construct" do
      construct[:attr_2] = "val_2"
      expect(construct.attr_2).to eq("val_2")
    end
  end
end
