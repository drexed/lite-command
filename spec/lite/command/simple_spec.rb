# frozen_string_literal: true

require 'spec_helper'

class FooSimpleCommand < Lite::Command::Simple; end

class BarSimpleCommand < Lite::Command::Simple

  def self.execute
    SecureRandom.hex(6)
  end

end

RSpec.describe Lite::Command::Simple do

  describe '.call' do
    it 'to be an Lite::Command::NotImplementedError error' do
      expect { FooSimpleCommand.call }.to raise_error(Lite::Command::NotImplementedError)
    end

    it 'to be 12 via class call' do
      result = BarSimpleCommand.call

      expect(result.size).to eq(12)
    end
  end

end
