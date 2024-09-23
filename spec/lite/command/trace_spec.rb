# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lite::Command::Trace do
  subject(:trace) do
    described_class.new(
      pass: 1,
      noop: 1,
      __noop_subtasks: 1,
      index: 3,
      position: %i[pass noop]
    )
  end

  describe ".increment" do
    context "when key value pair exists" do
      it "increments values of all keys passed" do
        trace.increment(:pass, :noop)
        expect(trace.to_h).to include(pass: 2, noop: 2)
      end
    end

    context "when key value pair missing" do
      it "sets the value to 0 then increments values of all keys passed" do
        trace.increment(:sampler)
        expect(trace.to_h).to include(sampler: 1)
      end
    end
  end

  describe ".advance" do
    it "increments the key value, removes lower values and returns a new trace" do
      other_trace = trace.advance(:noop)
      expect(other_trace.object_id).not_to eq(trace.object_id)
      expect(other_trace.to_h).to eq(pass: 1, noop: 2, index: 1, position: %i[noop])
    end
  end

  describe ".<=>" do
    context "when other trace is smaller" do
      it "returns correct value" do
        other_trace = described_class.new(index: 2)
        expect(trace <=> other_trace).to eq(1)
      end
    end

    context "when other trace is equal" do
      it "returns correct value" do
        other_trace = described_class.new(index: 3)
        expect(trace <=> other_trace).to eq(0)
      end
    end

    context "when other trace is larger" do
      it "returns correct value" do
        other_trace = described_class.new(index: 4)
        expect(trace <=> other_trace).to eq(-1)
      end
    end
  end

  describe ".to_position_fs" do
    it "returns correct position string format [pass.noop^noop_subtasks]" do
      expect(trace.to_position_fs).to eq("1^1")
    end
  end

  describe ".to_coordinates_fs" do
    it "returns correct coordinates string format [pass.noop^noop_subtasks]" do
      expect(trace.to_coordinates_fs).to eq("1.1^1")
    end
  end

  describe ".to_formatted_s" do
    it "returns correct trace string format [pass.noop^noop_subtasks]" do
      expect(trace.to_fs).to eq("3[1^1]")
    end
  end
end
