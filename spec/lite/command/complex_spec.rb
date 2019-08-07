# frozen_string_literal: true

require 'spec_helper'

class FooComplexService < Lite::Command::Complex; end

class BarComplexService < Lite::Command::Complex

  def initialize; end

  def command
    SecureRandom.hex(6)
  end

end

RSpec.describe Lite::Command::Complex do
  let(:foo) { FooComplexService.new }
  let(:bar) { BarComplexService.new }

  describe '.call' do
    it 'to be an Lite::Command::NotImplementedError error' do
      expect { foo.call }.to raise_error(Lite::Command::NotImplementedError)
    end

    it 'to be 12 via class call' do
      command = BarComplexService.call

      expect(command.result.size).to eq(12)
    end

    it 'to be 12 via instance call' do
      bar.call

      expect(bar.result.size).to eq(12)
    end

    it 'to be same random string twice' do
      bar.call
      first_result = bar.result

      bar.call
      second_result = bar.result

      expect(second_result).to eq(first_result)
    end
  end

  describe '.run' do
    it 'to be 12' do
      expect(BarComplexService.run.size).to eq(12)
    end
  end

  describe '.recall!' do
    it 'to be different random strings' do
      bar.call
      first_result = bar.result

      bar.recall!
      second_result = bar.result

      expect(second_result).not_to eq(first_result)
    end
  end

end
