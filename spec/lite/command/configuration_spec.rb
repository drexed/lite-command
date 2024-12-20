# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Configuration do
  after { Lite::Command.configuration.raise_dynamic_faults = true }

  describe "#configure" do
    it 'to be "foo"' do
      Lite::Command.configuration.raise_dynamic_faults = "foo"

      expect(Lite::Command.configuration.raise_dynamic_faults).to eq("foo")
    end
  end

  describe "#reset_configuration!" do
    it "to be false" do
      Lite::Command.configuration.raise_dynamic_faults = "foo"
      Lite::Command.reset_configuration!

      expect(Lite::Command.configuration.raise_dynamic_faults).to be(false)
    end
  end

end
