# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Construct do
  subject(:construct) { described_class.init(context) }

  let(:context) do
    { attr_one: "val_one" }
  end

  describe ".init" do
    it "creates a new open struct" do
      expect(construct.class).to eq(described_class)
      expect(construct.attr_one).to eq("val_one")
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
      construct[:attr_two] = "val_two"
      expect(construct.attr_two).to eq("val_two")
    end
  end
end
